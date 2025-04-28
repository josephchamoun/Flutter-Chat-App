import 'package:chatapp/Core/Network/DioClient.dart';
import 'package:chatapp/Core/ShowSuccessDialog.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends GetxController {
  late SharedPreferences prefs;
  late IO.Socket socket;

  int chatUserId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
  int? conversationId;
  int? authUserId;

  var messages = <Message>[].obs;
  var isLoading = true.obs; // Start with loading true

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void connectSocket() {
    socket = IO.io(
      'http://localhost:3000', // Change 'localhost' to your server IP if testing on real phone
      <String, dynamic>{
        'transports': ['websocket'], // Use websocket only
        'autoConnect': false, // We connect manually
      },
    );

    socket.connect();

    socket.onConnect((_) {
      print('[Socket.IO] Connected: ${socket.id}');

      // Join the correct conversation room after connecting
      if (conversationId != null) {
        socket.emit('joinConversation', conversationId);
      }
    });

    socket.onDisconnect((_) {
      print('[Socket.IO] Disconnected');
    });

    socket.on('newMessage', (data) {
      print('[Socket.IO] New message received: $data');

      // Parse the new message into your Message model
      Message newMsg = Message.fromJson(data);

      // Add the new message to the existing list
      messages.add(newMsg);
    });
  }

  // Load preferences and initialize chat
  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();

    // Initialize authUserId after prefs is loaded
    authUserId = prefs.getInt('user_id');

    // First create or get conversation
    await GetorCreateConversations();

    // Then get messages only if we have a valid conversation ID
    if (conversationId != null) {
      await GetMessages();
      connectSocket(); // Connect to socket after fetching messages
    }

    // DO NOT call _handleNavigation() here to prevent redirects
  }

  Future<void> GetorCreateConversations() async {
    print(
      "[ChatController] Creating or fetching conversation for user id: $chatUserId",
    );

    try {
      Converstation converstation = Converstation(userId: chatUserId);
      String requestBody = converstation.toJson();

      print("[ChatController] Request body: $requestBody");

      var post = await Dioclient().getInstance().post(
        '/conversations',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
          },
        ),
        data: requestBody,
      );

      print("[ChatController] Response status code: ${post.statusCode}");
      print("[ChatController] Response data: ${post.data}");

      if (post.statusCode != null &&
          post.statusCode! >= 200 &&
          post.statusCode! < 300) {
        print("[ChatController] Conversation creation successful ✅");
        conversationId = post.data['conversation']['id'];
      } else {
        print("[ChatController] Conversation creation failed ❌");
      }
    } catch (e) {
      print("[ChatController] Error during conversation creation ❗ Error: $e");
      if (Get.context != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowSuccessDialog(
            Get.context!,
            "Error",
            "Something went wrong creating conversation. Please try again.",
            () {},
          );
        });
      }
    }
  }

  Future<void> GetMessages() async {
    // Safety check - only proceed if we have a valid conversation ID
    if (conversationId == null) {
      print(
        "[ChatController] Cannot fetch messages: No conversation ID available",
      );
      isLoading.value = false;
      return;
    }

    try {
      print(
        "[ChatController] Fetching messages for conversation: $conversationId",
      );

      var response = await Dioclient().getInstance().get(
        '/messages/$conversationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
          },
        ),
      );

      print("[ChatController] Messages response: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data != null && response.data['messages'] != null) {
          var messagesList =
              (response.data['messages'] as List)
                  .map((message) => Message.fromJson(message))
                  .toList();

          messages.clear();
          messages.addAll(messagesList);

          print("[ChatController] Messages fetched: ${messages.length}");
        } else {
          messages.clear();
          print("[ChatController] No messages in response");
        }
      } else if (response.statusCode == 403) {
        // Handle 403 Unauthorized error
        messages.clear();
        print("[ChatController] Authorization error fetching messages");

        if (Get.context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowSuccessDialog(
              Get.context!,
              "Error",
              "You are not authorized to view this conversation.",
              () {},
            );
          });
        }
      } else {
        messages.clear();
        print(
          "[ChatController] Error fetching messages: ${response.statusCode}",
        );

        if (Get.context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowSuccessDialog(
              Get.context!,
              "Error",
              "Failed to fetch messages. Please try again.",
              () {},
            );
          });
        }
      }
    } catch (e) {
      messages.clear();
      print("[ChatController] Exception fetching messages: $e");

      if (Get.context != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowSuccessDialog(
            Get.context!,
            "Error",
            "Something went wrong fetching messages. Please try again.",
            () {},
          );
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Method to send a new message
  Future<void> sendMessage(String content) async {
    if (conversationId == null) {
      print("[ChatController] Cannot send message: No conversation ID");
      return;
    }

    if (content.trim().isEmpty) {
      return; // Don't send empty messages
    }

    try {
      var response = await Dioclient().getInstance().post(
        '/send-message',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {
          'conversation_id': conversationId,
          'message': content,
          'user_id': authUserId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh messages after sending
        await GetMessages();
      } else {
        print(
          "[ChatController] Failed to send message: ${response.statusCode}",
        );
        if (Get.context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowSuccessDialog(
              Get.context!,
              "Error",
              "Failed to send message. Please try again.",
              () {},
            );
          });
        }
      }
    } catch (e) {
      print("[ChatController] Error sending message: $e");
      if (Get.context != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowSuccessDialog(
            Get.context!,
            "Error",
            "Something went wrong sending your message. Please try again.",
            () {},
          );
        });
      }
    }
  }

  @override
  void onClose() {
    print("[ChatController] onClose called ❌");

    socket.dispose();
    super.onClose();
  }
}

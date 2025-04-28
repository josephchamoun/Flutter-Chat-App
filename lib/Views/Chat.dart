import 'package:chatapp/Controllers/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class Chat extends GetView<ChatController> {
  Chat({super.key});
  final receiverId = Get.parameters['id'];
  final TextEditingController messageController = TextEditingController();
  final String? userName = Get.arguments['userName'];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Listen to messages update to scroll to bottom
    controller.messages.listen((_) {
      // Wait for the next frame to ensure the UI updates before scrolling
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text("Chat with $userName")),
      body: Column(
        children: [
          // Messages list - takes most of the screen
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.messages.isEmpty) {
                return const Center(child: Text('No messages yet 📭'));
              } else {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    // Compare user_id with your user_id from prefs
                    final isMe =
                        message.userId == controller.prefs.getInt('user_id');

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show sender name if not your message
                            if (!isMe && message.user?.name != null)
                              Text(
                                message.user!.name!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            // Show message content
                            Text(
                              message.message ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),

          // Message input area at bottom
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji Button
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus(); // hide keyboard
                    controller.showEmojiPicker.value =
                        !controller.showEmojiPicker.value;
                  },
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                // Text field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onTap: () {
                      if (controller.showEmojiPicker.value) {
                        controller.showEmojiPicker.value = false;
                      }
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.sendMessage(value);
                        messageController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                InkWell(
                  onTap: () {
                    if (messageController.text.trim().isNotEmpty) {
                      controller.sendMessage(messageController.text);
                      messageController.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Emoji Picker
          Obx(() {
            if (controller.showEmojiPicker.value) {
              return SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    messageController.text += emoji.emoji;
                  },
                  config: Config(columns: 7, emojiSizeMax: 32),
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
        ],
      ),
    );
  }
}






/*
Column(
  children: [
    Expanded(...), // message list
    Row(...), // emoji + input + send
    Obx(...), // emoji picker
  ],
)
*/
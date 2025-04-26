import 'package:chatapp/Core/Network/DioClient.dart';
import 'package:chatapp/Core/ShowSuccessDialog.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  late SharedPreferences prefs;
  int chatUserId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

  @override
  void onInit() {
    super.onInit();
    print("[ChatController] onInit called ✅");
    _initialize();
  }

  void _initialize() async {
    print("[ChatController] Initializing...");
    await _loadPrefs();
    print("[ChatController] Prefs loaded ✅");
    GetorCreateConversations();
  }

  Future<void> _loadPrefs() async {
    print("[ChatController] Loading SharedPreferences...");
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      print("[ChatController] No token found ❌. Redirecting to login...");
      Get.offAllNamed('/login');
    } else {
      print("[ChatController] Token found ✅: ${prefs.getString('token')}");
    }
  }

  void GetorCreateConversations() async {
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
        ShowSuccessDialog(
          Get.context!,
          "Success",
          post.data['message'] ?? "Conversation created successfully",
          () {},
        );
      } else {
        print("[ChatController] Conversation creation failed ❌");
        ShowSuccessDialog(
          Get.context!,
          "Error",
          post.data?['message'] ?? "Failed to create conversation",
          () {},
        );
      }
    } catch (e) {
      print("[ChatController] Error during conversation creation ❗ Error: $e");
      ShowSuccessDialog(
        Get.context!,
        "Error",
        "Something went wrong. Please try again.",
        () {},
      );
    }
  }

  @override
  void onClose() {
    print("[ChatController] onClose called ❌");
    super.onClose();
  }
}

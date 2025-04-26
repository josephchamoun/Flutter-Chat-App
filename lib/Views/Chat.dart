import 'package:chatapp/Controllers/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends GetView<ChatController> {
  Chat({super.key});
  final receiverId = Get.parameters['id'];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.GetorCreateConversations();
    });

    return Scaffold(appBar: AppBar(title: Text("Chat with user $receiverId")));
  }
}

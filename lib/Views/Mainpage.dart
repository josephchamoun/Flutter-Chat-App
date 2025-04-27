import 'package:chatapp/Controllers/MainpageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Mainpage extends GetView<MainpageController> {
  Mainpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users List")),
      body: Obx(() {
        // Check if the users list is empty or still loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.users.isEmpty) {
          return const Center(child: Text("No users found."));
        } else {
          return ListView.builder(
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return ListTile(
                title: Text(user.name ?? "No Name"),
                subtitle: Text(user.email ?? "No Email"),
                onTap: () {
                  Get.toNamed(
                    '/chat/${user.id}',
                    arguments: {'userName': user.name, 'userEmail': user.email},
                  );
                },
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.listofUsers,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

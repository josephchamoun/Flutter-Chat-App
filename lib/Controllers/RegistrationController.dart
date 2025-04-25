import 'package:chatapp/Core/ShowSuccessDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Core/Network/DioClient.dart';
import '../Models/User.dart';

class RegistrationController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController password_confirmation = TextEditingController();

  // This method handles the form submission
  void submit() {
    String nameValue = name.text.trim();
    String emailValue = email.text.trim();
    String passwordValue = password.text.trim();
    String passwordConfirmationValue = password_confirmation.text.trim();

    if (nameValue.isEmpty) {
      Get.snackbar("Error", "Please enter your name.");
    } else if (emailValue.isEmpty) {
      Get.snackbar("Error", "Please enter a valid email.");
    } else if (passwordValue.isEmpty) {
      Get.snackbar("Error", "Please enter your password.");
    } else if (passwordValue.length < 8) {
      Get.snackbar("Error", "Password must be at least 8 characters long");
    } else if (passwordValue != passwordConfirmationValue) {
      Get.snackbar("Error", "Passwords do not match.");
    } else {
      register();
    }
  }

  @override
  void onClose() {
    // Dispose controllers when no longer needed
    email.dispose();
    name.dispose();
    password.dispose();
    password_confirmation.dispose();
    super.onClose();
  }

  void register() async {
    try {
      User user = User(
        name: name.text,
        email: email.text,
        password: password.text,
        password_confirmation: password_confirmation.text,
      );

      String requestBody = user.toJson();

      var post = await Dioclient().getInstance().post(
        '/register',
        data: requestBody,
      );

      if (post.statusCode != null &&
          post.statusCode! >= 200 &&
          post.statusCode! < 300) {
        ShowSuccessDialog(
          Get.context!,
          "Success",
          post.data['message'] ?? "User Registered Successfully",
          () {},
        );
      } else {
        ShowSuccessDialog(
          Get.context!,
          "Error",
          post.data?['message'] ?? "User Registration Failed",
          () {},
        );
      }
    } catch (e) {
      // Catch any exceptions and display a failure message
      ShowSuccessDialog(
        Get.context!,
        "Error",
        "Something went wrong. Please try again.",
        () {},
      );
    }
  }
}

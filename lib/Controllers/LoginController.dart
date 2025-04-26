import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Core/Network/DioClient.dart';
import '../Core/ShowSuccessDialog.dart';
import '../Models/User.dart';

class LoginController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  late SharedPreferences prefs;
  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      Get.offAllNamed('/mainpage');
    }
  }

  void submit() {
    String emailValue = email.text.trim();
    String passwordValue = password.text.trim();

    if (emailValue.isEmpty || !GetUtils.isEmail(emailValue)) {
      Get.snackbar("Error", "Please enter a valid email.");
    } else if (passwordValue.isEmpty) {
      Get.snackbar("Error", "Please enter your password.");
    } else {
      login();
    }
  }

  @override
  void onClose() {
    // Dispose controllers when no longer needed
    email.dispose();
    password.dispose();
    super.onClose();
  }

  void login() async {
    try {
      // Create a User object with email and password
      User user = User(email: email.text, password: password.text);

      // Convert the User object to JSON
      String requestBody = user.toJson();

      // Send a POST request to the login endpoint
      var response = await Dioclient().getInstance().post(
        '/login',
        data: requestBody,
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        if (response.data != null &&
            response.data['message'] == 'Login successful') {
          // Save token and user details in SharedPreferences
          prefs.setString('token', response.data['token']);
          prefs.setInt('user_id', response.data['user']['id']);
          prefs.setString('user_name', response.data['user']['name']);
          prefs.setString('user_email', response.data['user']['email']);

          // Show success dialog
          ShowSuccessDialog(
            Get.context!,
            "Success",
            "User Login Successfully",
            () {},
          );

          // Navigate to the main page
          Get.offAllNamed('/mainpage');
        } else {
          // Show failure dialog if login fails
          ShowSuccessDialog(Get.context!, "Failed", "User Login Failed", () {});
        }
      } else {
        // Show error dialog for invalid credentials
        ShowSuccessDialog(
          Get.context!,
          "Failed",
          "Wrong email or password",
          () {},
        );
      }
    } catch (e) {
      // Handle exceptions and show error dialog
      print("Error during login: $e");
      ShowSuccessDialog(
        Get.context!,
        "Error",
        "Something went wrong. Please try again.",
        () {},
      );
    }
  }
}

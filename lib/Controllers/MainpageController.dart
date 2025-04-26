import 'package:chatapp/Core/Network/DioClient.dart';
import 'package:chatapp/Core/ShowSuccessDialog.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/User.dart';

class MainpageController extends GetxController {
  late SharedPreferences prefs;
  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      Get.offAllNamed('/login');
    } else {
      authUserId = prefs.getInt('user_id');
      listofUsers(); // Fetch users when the controller is initialized
    }
  }

  var users = <User>[].obs; // Observable list of users
  var isLoading = false.obs; // Observable loading state
  int? authUserId;

  void listofUsers() async {
    isLoading.value = true; // Set loading to true
    try {
      var response = await Dioclient().getInstance().get(
        '/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
          },
        ),
      );

      print("Response: ${response.data}"); // Debug log to inspect the response

      if (response.statusCode == 200) {
        if (response.data != null && response.data['users'] != null) {
          var allUsers =
              (response.data['users'] as List)
                  .map((user) => User.fromJson(user))
                  .toList();

          users.value =
              allUsers.where((user) => user.id != authUserId).toList();
          print("Users fetched: ${users.length}"); // Debug log for users
        } else {
          users.clear();
          _showErrorDialog("Failed to fetch users. Please try again.");
        }
      } else {
        users.clear();
        _showErrorDialog("Failed to fetch users. Server error.");
      }
    } catch (e) {
      users.clear();
      print("Error fetching users: $e");
      _showErrorDialog("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }

  void _showErrorDialog(String message) {
    ShowSuccessDialog(Get.context!, "Error", message, () {});
  }
}

import 'package:chatapp/Controllers/MainpageController.dart';
import 'package:get/get.dart';

class MainpageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainpageController());
  }
}

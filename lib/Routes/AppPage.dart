import 'package:chatapp/Bindings/LoginBinding.dart';
import 'package:chatapp/Bindings/RegistrationBinding.dart';
import 'package:chatapp/Routes/AppRoute.dart';
import 'package:chatapp/Views/Login.dart';
import 'package:chatapp/Views/Registration.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPage {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoute.register,
      page: () => Registration(),
      binding: RegistrationBinding(),
    ),
    GetPage(name: AppRoute.login, page: () => Login(), binding: LoginBinding()),
  ];
}

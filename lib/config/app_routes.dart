import 'package:get/get.dart';
import 'package:tailors_connect/screens/loginscreen/tailorlogin.dart';
import 'package:tailors_connect/screens/loginscreen/userlogin.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';

class AppRoutes {
  static const String loginInfo = '/login-info';
  static const String userLogin = '/user-login';
  static const String tailorLogin = '/tailor-login';

  static List<GetPage> routes = [
    GetPage(name: loginInfo, page: () => const LoginInfo()),
    GetPage(name: userLogin, page: () => const UserLoginPage()),
    GetPage(name: tailorLogin, page: () => const TailorLoginPage()),
  ];
}

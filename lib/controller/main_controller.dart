import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';
import 'package:tailors_connect/screens/tailorscreen/tailorhome.dart';
import 'package:tailors_connect/screens/userscreen/userhome.dart';

class MainController extends GetxController {
  Rx<Widget> initialPage = Rx<Widget>(const LoginInfo());

  // This is the method we will call asynchronously in main.dart
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final int? userType = prefs.getInt('userType');

    if (isLoggedIn) {
      if (userType == 1) {
        initialPage.value = const UserHome();
      } else if (userType == 2) {
        initialPage.value = const TailorHomePage();
      } else {
        initialPage.value = const LoginInfo();
      }
    } else {
      initialPage.value = const LoginInfo();
    }
  }
}

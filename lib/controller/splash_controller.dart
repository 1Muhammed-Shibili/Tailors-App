import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';
import 'package:tailors_connect/screens/tailorscreen/tailorhome.dart';
import 'package:tailors_connect/screens/userscreen/userhome.dart';

class SplashScreenController extends GetxController {
  RxDouble opacityLevel = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    animateSplash();
  }

  Future<void> animateSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    opacityLevel.value = 1.0;
    await Future.delayed(const Duration(seconds: 2));
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getInt('userType') ?? 0;

    if (isLoggedIn) {
      if (userType == 1) {
        Get.off(() => const UserHome());
      } else if (userType == 2) {
        Get.off(() => const TailorHomePage());
      }
    } else {
      Get.off(() => const LoginInfo());
    }
  }
}

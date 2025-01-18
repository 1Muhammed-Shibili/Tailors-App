import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailors_connect/controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashScreenController controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFd6e1e4),
        width: double.infinity,
        height: double.infinity,
        child: Obx(() {
          return AnimatedOpacity(
            opacity: controller.opacityLevel.value,
            duration: const Duration(seconds: 1),
            child: Image.asset(
              'assets/splashscreen.png',
              height: 50,
              width: 50,
            ),
          );
        }),
      ),
    );
  }
}

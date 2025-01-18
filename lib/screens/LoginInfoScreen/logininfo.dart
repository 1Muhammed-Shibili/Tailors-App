import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailors_connect/config/app_routes.dart';

class LoginInfo extends StatelessWidget {
  const LoginInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/logininfopage.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 85, vertical: 14),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.userLogin);
                      },
                      child: const Text('User Login'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 300,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.tailorLogin);
                  },
                  child: const Text(
                    'Tailors Login',
                    style: TextStyle(fontSize: 14.5, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailors_connect/Firebase/firebase_options.dart';
import 'package:tailors_connect/controller/main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Get.putAsync(() async {
    final controller = MainController();
    await controller.initialize();
    return controller;
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tailor Connect',
      home: Obx(() {
        return Get.find<MainController>().initialPage.value;
      }),
    );
  }
}

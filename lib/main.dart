import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/firebase_options.dart';
import 'package:tailors_connect/screens/logininfo.dart';
import 'package:tailors_connect/tailorscreen/tailorhome.dart';
import 'package:tailors_connect/userscreen/userhome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final int? userType = prefs.getInt('userType');

  Widget initialPage;

  if (isLoggedIn) {
    if (userType == 1) {
      initialPage = const UserHome();
    } else if (userType == 2) {
      initialPage = const TailorHomePage();
    } else {
      initialPage = const LoginInfo();
    }
  } else {
    initialPage = const LoginInfo();
  }

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tailor Connect',
      home: initialPage,
    );
  }
}

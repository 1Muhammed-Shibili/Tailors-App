import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/screens/StartScreen/get_start.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';
import 'package:tailors_connect/screens/tailorscreen/tailorhome.dart';
import 'package:tailors_connect/screens/userscreen/userhome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    animateSplash();
    _checkLoginStatus();
  }

  Future<void> animateSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      opacityLevel = 1.0;
    });
    await Future.delayed(const Duration(seconds: 2));
    gotologin(context);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getInt('userType') ?? 0;

    if (isLoggedIn) {
      if (userType == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UserHome()),
        );
      } else if (userType == 2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TailorHomePage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginInfo()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFd6e1e4),
        width: double.infinity,
        height: double.infinity,
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(seconds: 1),
          child: Image.asset(
            'assets/splashscreen.png',
            height: 50,
            width: 50,
          ),
        ),
      ),
    );
  }
}

Future<void> gotologin(context) async {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (ctx) => const GetStartPage()),
  );
}

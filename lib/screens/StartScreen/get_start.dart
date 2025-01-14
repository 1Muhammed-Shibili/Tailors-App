import 'package:flutter/material.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';

class GetStartPage extends StatelessWidget {
  const GetStartPage({super.key});

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
                'assets/getstartpage.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'Connect With \nTailors',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 65, vertical: 13),
                        backgroundColor: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (ctx) => const LoginInfo()),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

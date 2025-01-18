import 'package:flutter/material.dart';

class UserEnterPinPage extends StatelessWidget {
  const UserEnterPinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            PinTextField(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Validate and process the entered PIN
                // You can implement the logic for verifying the entered PIN
                // and navigating to the appropriate screen accordingly.
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class PinTextField extends StatefulWidget {
  @override
  _PinTextFieldState createState() => _PinTextFieldState();
}

class _PinTextFieldState extends State<PinTextField> {
  TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: pinController,
      keyboardType: TextInputType.number,
      obscureText: true,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        hintText: 'Enter your PIN',
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

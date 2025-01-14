import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailors_connect/screens/loginscreen/tailorlogin.dart';
import 'package:tailors_connect/config/decorations.dart';

class TailorForgotPassword extends StatelessWidget {
  TailorForgotPassword({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

// Function to reset password using the provided email
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      // Send a password reset email to the provided email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
      // You can display a success message or navigate the user to a confirmation screen
      print('Password reset email sent successfully.');
    } catch (e) {
      // Handle errors such as invalid email, user not found, etc.
      print('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 90),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, top: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter e-mail address', style: forgotstyle()),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'Email Address',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.mail_outline_sharp),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Enter new password', style: forgotstyle()),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: newPasswordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'minimum 8 digits',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock_outline_sharp),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Confrim Password', style: forgotstyle()),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        suffixIcon: Icon(Icons.remove_red_eye_outlined),
                        prefixIcon: Icon(Icons.lock_outline_sharp),
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 140, vertical: 15),
                            backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (ctx) => const TailorLoginPage()),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

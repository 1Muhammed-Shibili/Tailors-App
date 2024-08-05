import 'package:flutter/material.dart';
import 'package:tailors_connect/enter_pin/email_pin.dart';
import 'package:tailors_connect/loginscreen/validation.dart';
import 'package:tailors_connect/screens/decorations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserForgotPassword extends StatefulWidget {
  UserForgotPassword({super.key});

  @override
  State<UserForgotPassword> createState() => _UserForgotPasswordState();
}

class _UserForgotPasswordState extends State<UserForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully.');
    } catch (e) {
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
          child: Form(
            key: _formKey,
            child: Column(children: [
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
                        validator: validateEmailAddress,
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
                        validator: validatePassword,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          hintText: 'minimum 6 digits',
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
                        validator: validatePassword,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          prefixIcon: const Icon(Icons.lock_outline_sharp),
                        ),
                      ),
                      const SizedBox(height: 35),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                              backgroundColor: Colors.red),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Validation passed, proceed with password reset
                              String email = emailController.text;
                              String newPassword = newPasswordController.text;

                              resetPassword(email, newPassword);

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (ctx) => const UserEnterPinPage()),
                              );
                            }
                          },
                          child: const Text('Reset Password'),
                        ),
                      ),
                    ]),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tailors_connect/enter_pin/email_pin.dart';
import 'package:tailors_connect/loginscreen/validation.dart';
import 'package:tailors_connect/screens/decorations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserForgotPassword extends StatefulWidget {
  const UserForgotPassword({super.key});

  @override
  State<UserForgotPassword> createState() => _UserForgotPasswordState();
}

class _UserForgotPasswordState extends State<UserForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> resetPassword(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email address.')),
        );
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset email sent successfully.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const UserEnterPinPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                      child: Text('Forgot Password',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, top: 55),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter e-mail address', style: forgotstyle()),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
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
                      const SizedBox(height: 35),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 65, vertical: 13),
                              backgroundColor: Colors.red),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String email = emailController.text;
                              resetPassword(email);
                            }
                          },
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Reset Password'),
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

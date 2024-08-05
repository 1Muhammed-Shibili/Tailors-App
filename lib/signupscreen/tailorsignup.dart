import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailors_connect/loginscreen/tailorlogin.dart';
import 'package:tailors_connect/loginscreen/validation.dart';
import 'package:tailors_connect/screens/decorations.dart';

class TailorSignUpPage extends StatefulWidget {
  const TailorSignUpPage({super.key});

  @override
  State<TailorSignUpPage> createState() => _TailorSignUpPageState();
}

class _TailorSignUpPageState extends State<TailorSignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final formkey = GlobalKey<FormState>();

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/signuppage.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 45, left: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    height: 555,
                    decoration: customContainer(),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create account',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            'Quickly Create account',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 17),
                            child: Form(
                              key: formkey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      hintText: 'Username',
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(Icons.person_rounded),
                                    ),
                                    validator: validateUsername,
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      hintText: 'Email Address',
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon:
                                          Icon(Icons.mail_outline_sharp),
                                    ),
                                    validator: validateEmailAddress,
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Password',
                                      suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                          child: Icon(_isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off)),
                                      prefixIcon:
                                          const Icon(Icons.lock_outline_sharp),
                                    ),
                                    validator: validatePassword,
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Confirm Password',
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                        child: Icon(_isConfirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ),
                                      prefixIcon: const Icon(
                                          Icons.lock_person_outlined),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      } else if (value !=
                                          _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 110, vertical: 13),
                                      backgroundColor: Colors.red),
                                  onPressed: () async {
                                    if (formkey.currentState!.validate()) {
                                      showLoadingDialog(context);

                                      try {
                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );

                                        await FirebaseFirestore.instance
                                            .collection('tailors')
                                            .doc(userCredential.user!.uid)
                                            .set({
                                          'username': _usernameController.text,
                                          'email': _emailController.text,
                                        });

                                        await userCredential.user!
                                            .updateDisplayName(
                                                _usernameController.text);

                                        hideLoadingDialog(context);

                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Registration Successful'),
                                              content: const Text(
                                                  'You have successfully registered.'),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                    Future.delayed(
                                                      Duration.zero,
                                                      () {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                const TailorLoginPage(),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Text('Continue'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        hideLoadingDialog(context);

                                        if (e.code == 'weak-password') {
                                          print(
                                              'The password provided is too weak.');
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          print(
                                              'The account already exists for that email.');
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('SignUp'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) => const TailorLoginPage()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account ?',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Login',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/forgotpassword/tailorforgot.dart';
import 'package:tailors_connect/screens/loginscreen/validation.dart';
import 'package:tailors_connect/config/decorations.dart';
import 'package:tailors_connect/screens/signupscreen/tailorsignup.dart';
import 'package:tailors_connect/screens/tailorscreen/tailorhome.dart';

class TailorLoginPage extends StatefulWidget {
  const TailorLoginPage({super.key});

  @override
  State<TailorLoginPage> createState() => _TailorLoginPageState();
}

class _TailorLoginPageState extends State<TailorLoginPage> {
  bool _isPasswordVisible = false;

  final formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
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
              'assets/loginscreen.png',
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
                    height: 403,
                    decoration: customContainer(),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                                fontSize: 23,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            'Sign in into your account',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 17),
                            child: Form(
                              key: formkey,
                              child: Column(children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    hintText: 'Email Address',
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Icon(Icons.mail_outline_sharp),
                                  ),
                                  validator: validateEmailAddress,
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      TailorForgotPassword()),
                                            );
                                          },
                                          child: const Text('Forgot Password',
                                              style: TextStyle(
                                                  color: Colors.blue)),
                                        ),
                                      ]),
                                )
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
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
                                      try {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        );
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text);

                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setInt('userType', 2);
                                        await prefs.setBool('isLoggedIn', true);

                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const TailorHomePage()),
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        Navigator.of(context).pop();
                                        if (e.code == 'user-not-found' ||
                                            e.code == 'wrong-password') {
                                          _showErrorDialog(
                                              'Invalid email or password');
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          _showErrorDialog(
                                              'The account already exists for that email.');
                                        } else {
                                          _showErrorDialog(e.message!);
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) => const TailorSignUpPage()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don’t have an account ? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Sign up',
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

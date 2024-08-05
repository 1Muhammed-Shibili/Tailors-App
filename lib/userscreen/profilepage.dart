import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tailors_connect/screens/decorations.dart';
import 'package:tailors_connect/userscreen/userhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool uploadingImage = false;
  bool loadingImage = false;
  bool errorLoadingImage = false;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchShopDetailsFromFirestore();
  }

  void _initializeControllers() {
    User? user = FirebaseAuth.instance.currentUser;
    _usernameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        uploadingImage = true;
        errorLoadingImage = false;
      });

      await _pickImage();
      setState(() {
        loadingImage = true;
      });

      String downloadURL = await _uploadImage();
      setState(() {
        imageUrl = downloadURL;
      });
    } catch (e) {
      print('Error picking and uploading image: $e');
      setState(() {
        errorLoadingImage = true;
      });
    } finally {
      setState(() {
        uploadingImage = false;
        loadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String> _uploadImage() async {
    try {
      if (imageUrl != null) {
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(
                  'shop_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
                );

        await ref.putFile(File(imageUrl!));

        String downloadURL = await ref.getDownloadURL();
        return downloadURL;
      } else {
        print('No image selected');
        return '';
      }
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _fetchShopDetailsFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot shopSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (shopSnapshot.exists) {
          setState(() {
            _usernameController.text = shopSnapshot['username'];
            _emailController.text = shopSnapshot['email'];
            _passwordController.text = shopSnapshot['password'];
            imageUrl = shopSnapshot['profile_pic'];
          });
        }
      }
    } catch (e) {
      print('Error fetching shop details from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              Stack(children: [
                Container(
                  color: Colors.red,
                  width: double.infinity,
                  height: 130,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 55),
                    child: Text('Profile', style: customTextStyle()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            height: 170,
                            width: 170,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: 4, color: const Color(0xFFfdebea))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: _buildImageWidget(),
                            ),
                          ),
                        ),
                      ]),
                )
              ]),
              const SizedBox(height: 5),
              const Text('Profile Picture'),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username', style: customTextStyle2()),
                    const SizedBox(height: 5),
                    TextFormField(
                        controller: _usernameController,
                        decoration: customInputDecoration('Username')),
                    const SizedBox(height: 15),
                    Text('Email', style: customTextStyle2()),
                    const SizedBox(height: 5),
                    TextFormField(
                        controller: _emailController,
                        decoration: customInputDecoration('Email Address')),
                    const SizedBox(height: 15),
                    Text('Password', style: customTextStyle2()),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: customInputDecoration('Password')),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 140, vertical: 15),
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            await UpdateFirebase(
                              _usernameController.text,
                              _emailController.text,
                              _passwordController.text,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Profile updated successfully!')),
                            );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (ctx) => const UserHome()),
                            );
                          },
                          child: const Text('Save'),
                        ),
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

  Widget _buildImageWidget() {
    if (uploadingImage) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (imageUrl != null) {
      return loadingImage
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Image.network(
              '$imageUrl',
              fit: BoxFit.cover,
            );
    } else {
      return const Center(child: Icon(Icons.add_a_photo, color: Colors.grey));
    }
  }

  Future<void> UpdateFirebase(
    String username,
    String email,
    String password,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        };

        if (imageUrl != null) {
          updateData['profile_pic'] = imageUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);
      }
    } catch (e) {
      print('Error updating shop details: $e');
    }
  }
}
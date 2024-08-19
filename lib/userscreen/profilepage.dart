import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tailors_connect/screens/decorations.dart';
//import 'package:tailors_connect/userscreen/userhome.dart';
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
            imageUrl = shopSnapshot['profile_pic'];
            loadingImage = false;
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
                        Container(
                          height: 170,
                          width: 170,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 4, color: Colors.white),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: imageUrl != null && imageUrl!.isNotEmpty
                                    ? Image.network(
                                        imageUrl!,
                                        width: 170,
                                        height: 170,
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _pickAndUploadImage,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: Colors.white),
                                    ),
                                    child: const Icon(Icons.add_a_photo,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
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
                        enabled: false,
                        controller: _emailController,
                        decoration: customInputDecoration('Email Address')),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 85, vertical: 10),
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _saveProfileChanges,
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ),
                    // const Padding(
                    //   padding: EdgeInsets.only(left: 190),
                    //   child: Text('Reset Password',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.blue,
                    //       )),
                    // ),
                    // const SizedBox(height: 10),
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
    } else if (loadingImage) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      );
    } else {
      return const Center(child: Icon(Icons.add_a_photo, color: Colors.grey));
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userRef.update({
          'username': _usernameController.text,
          'profile_pic': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
}

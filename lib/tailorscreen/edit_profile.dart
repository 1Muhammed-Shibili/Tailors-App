import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tailors_connect/tailorscreen/tailorhome.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool uploadingImage = false;
  bool loadingImage = false;
  bool errorLoadingImage = false;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchShopDetailsFromFirestore();
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
            .collection('shops')
            .doc(user.uid)
            .get();

        if (shopSnapshot.exists) {
          setState(() {
            _shopNameController.text = shopSnapshot['shopName'];
            _cityController.text = shopSnapshot['city'];
            _phoneNumberController.text = shopSnapshot['phoneNumber'];
            _descriptionController.text = shopSnapshot['description'];

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
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/2.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, left: 15),
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
            padding: EdgeInsets.only(top: 75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Shop details',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, right: 15, left: 15),
            child: Container(
              height: 700,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xB3fd3c38),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await _pickAndUploadImage();
                          } catch (e) {
                            print('Error picking and uploading image: $e');
                          }
                        },
                        child: Container(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: uploadingImage
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                )
                              : imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: loadingImage
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blue,
                                              ),
                                            )
                                          : Image.network(
                                              imageUrl!,
                                              width: 175,
                                              height: 175,
                                              fit: BoxFit.cover,
                                            ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                      ),
                                    ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 20),
                        child: Column(
                          children: [
                            TextFormField(
                              maxLength: 19,
                              controller: _shopNameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                hintText: 'Shop name',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.person_pin_outlined),
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              maxLength: 40,
                              controller: _cityController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                hintText: 'Shop Address',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                hintText: 'Phone number',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a phone number';
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be exactly 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 5),
                            SingleChildScrollView(
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText:
                                      'short description about your store',
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.description_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 140, vertical: 15),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                if (_phoneNumberController.text.length != 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Phone number must be exactly 10 digits'),
                                    ),
                                  );
                                  return;
                                }

                                UpdateFirebase(
                                  _cityController.text,
                                  _phoneNumberController.text,
                                  _descriptionController.text,
                                  _shopNameController.text,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Profile updated successfully!'),
                                  ),
                                );

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (ctx) => const TailorHomePage(),
                                  ),
                                );
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> UpdateFirebase(
    String citycontroller,
    String phonenumber,
    String description,
    String shopname,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          "city": citycontroller,
          "description": description,
          "phoneNumber": phonenumber,
          "shopName": shopname,
        };

        if (imageUrl != null) {
          updateData['profile_pic'] = imageUrl;
        }

        DocumentSnapshot shopSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .doc(user.uid)
            .get();

        if (shopSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(user.uid)
              .update(updateData);
        } else {
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(user.uid)
              .set(updateData);
        }
      }
    } catch (e) {
      print('Error updating shop details: $e');
    }
  }
}

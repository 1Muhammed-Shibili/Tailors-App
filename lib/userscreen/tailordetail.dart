import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tailors_connect/userscreen/reviewscreen/workreview.dart';

class TailorDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> tailorData;

  const TailorDetailsPage({required this.tailorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: Padding(
        padding: const EdgeInsets.only(top: 35),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
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
                      padding: EdgeInsets.only(left: 137),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 750,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 26,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                tailorData['profile_pic'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              tailorData['shopName'],
                              style: const TextStyle(
                                  fontSize: 19,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    tailorData['city'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone_outlined,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                const Text(
                                  'Phone: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  tailorData['phoneNumber'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfdebea),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                height: 309,
                                width: 350,
                                child: SingleChildScrollView(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: _parseDescription(
                                          tailorData['description']),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    TextEditingController messageController =
                                        TextEditingController();
                                    File? selectedImage;

                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: const Text('Send Request'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        messageController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Enter your message',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    onPressed: () async {
                                                      File? pickedImage =
                                                          await _pickImage();
                                                      setState(() {
                                                        selectedImage =
                                                            pickedImage;
                                                      });
                                                    },
                                                    child: const Text(
                                                        'Add Picture'),
                                                  ),
                                                  if (selectedImage != null)
                                                    Container(
                                                      height: 70,
                                                      width: 70,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        image: DecorationImage(
                                                          image: FileImage(
                                                              selectedImage!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () async {
                                                    String message =
                                                        messageController.text
                                                            .trim();
                                                    String uid = FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid;

                                                    String imageUrl = '';
                                                    if (selectedImage != null) {
                                                      final ref = FirebaseStorage
                                                          .instance
                                                          .ref()
                                                          .child('requests')
                                                          .child(
                                                              '${DateTime.now().millisecondsSinceEpoch}.jpg');
                                                      await ref.putFile(
                                                          selectedImage!);
                                                      imageUrl = await ref
                                                          .getDownloadURL();
                                                    }

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('requests')
                                                        .add({
                                                      'message': message,
                                                      'senderUid': uid,
                                                      'receiverUid': tailorData[
                                                          'tailorId'],
                                                      'imageUrl': imageUrl,
                                                    });

                                                    Navigator.pop(context);

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Request Sent'),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('Send'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Request for stitching'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (ctx) => WorksAndReviews(
                                                tailorId: tailorData.id,
                                              )),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 2,
                                        )),
                                    height: 44,
                                    width: 150,
                                    child: const Center(
                                      child: Text(
                                        'Works and Reviews',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  List<TextSpan> _parseDescription(String description) {
    List<String> lines = description.split('\n');
    List<TextSpan> children = [];
    for (int i = 0; i < lines.length; i++) {
      children.add(TextSpan(text: lines[i]));
      if (i != lines.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }
    return children;
  }
}

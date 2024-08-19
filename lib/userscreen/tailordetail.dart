import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TailorDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> tailorData;

  const TailorDetailsPage({required this.tailorData});

  @override
  State<TailorDetailsPage> createState() => _TailorDetailsPageState();
}

class _TailorDetailsPageState extends State<TailorDetailsPage> {
  final TextEditingController messageController = TextEditingController();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    String description = widget.tailorData['description'] ?? '';
    String displayDescription = description.length > 150
        ? '${description.substring(0, 150)}...'
        : description;

    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 10),
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
                const Spacer(),
                const Text(
                  'Profile',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 2, right: 10, left: 10, bottom: 10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.tailorData['profile_pic'],
                            width: 175,
                            height: 175,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.tailorData['shopName'],
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                widget.tailorData['city'],
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
                              widget.tailorData['phoneNumber'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.63,
                                top: 13,
                                bottom: 10),
                            child: const Text('What we Offer',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ))),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 7, bottom: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfdebea),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  children:
                                      _parseDescription(displayDescription),
                                ),
                              ),
                              if (description.length > 150)
                                GestureDetector(
                                  onTap: () {
                                    _showFullDescriptionDialog(description);
                                  },
                                  child: const Text(
                                    'See More',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.64,
                                top: 15),
                            child: const Text('Our Works...',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ))),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('shops')
                              .doc(widget.tailorData.id)
                              .collection('images')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasData) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 2,
                                        mainAxisSpacing: 3),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final worksReview =
                                      snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      _showImageDialog(
                                          context, worksReview['url']);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                worksReview['url']),
                                            fit: BoxFit.scaleDown),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return const Text(
                              'No images available',
                              style: TextStyle(color: Colors.black),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(1.5),
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 50, vertical: 12.5),
          //       backgroundColor: Colors.red,
          //     ),
          //     onPressed: _sendRequest,
          //     child: const Text('Request for stitching'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> _sendRequest() async {
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
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your message',
                    ),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      File? pickedImage = await _pickImage();
                      setState(() {
                        selectedImage = pickedImage;
                      });
                    },
                    child: const Text('Add Picture'),
                  ),
                  if (selectedImage != null)
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(selectedImage!),
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
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    String message = messageController.text.trim();

                    if (message.isEmpty) {
                      _showError('Please enter a message');
                      return;
                    }

                    if (selectedImage == null) {
                      _showError('Please select an image');
                      return;
                    }

                    try {
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        _showError('User not authenticated');
                        return;
                      }

                      String imageUrl = await _uploadImage(selectedImage!);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('requests')
                          .add({
                        'message': message,
                        'imageUrl': imageUrl,
                        'tailorId': widget.tailorData.id,
                        'status': 'pending',
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request sent successfully'),
                        ),
                      );

                      messageController.clear();
                      setState(() {
                        selectedImage = null;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      _showError('Error: ${e.toString()}');
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<File?> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> _uploadImage(File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final storageRef = FirebaseStorage.instance.ref().child(
        'request_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = storageRef.putFile(image);

    TaskSnapshot storageSnapshot = await uploadTask;
    return await storageSnapshot.ref.getDownloadURL();
  }

  List<TextSpan> _parseDescription(String description) {
    List<TextSpan> spans = [];
    List<String> parts = description.split(' ');

    for (String part in parts) {
      spans.add(
        TextSpan(
          text: '$part ',
          style: TextStyle(
            color: part.startsWith('#') ? Colors.blue : Colors.black,
            fontWeight:
                part.startsWith('#') ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }
    return spans;
  }

  void _showFullDescriptionDialog(String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 218, 207, 206),
          title: const Text('Full Description'),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(imageUrl),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

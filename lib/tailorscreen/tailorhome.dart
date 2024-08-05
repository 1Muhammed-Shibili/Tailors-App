import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/screens/logininfo.dart';
import 'package:tailors_connect/tailorscreen/edit_profile.dart';
import 'package:tailors_connect/tailorscreen/recieve_request.dart';

class TailorHomePage extends StatefulWidget {
  const TailorHomePage({super.key});

  @override
  State<TailorHomePage> createState() => _TailorHomePageState();
}

class _TailorHomePageState extends State<TailorHomePage> {
  List<String> imageUrls = [];
  String tailorName = '';
  String tailorLocation = '';
  String tailorPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchShopDetailsFromFirestore();
  }

  Stream<DocumentSnapshot> _fetchShopDetailsFromFirestore() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('shops')
          .doc(user.uid)
          .snapshots();
    }
    return Stream.empty();
  }

  Future<void> saveImageToFirestore(String imageUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference images =
            FirebaseFirestore.instance.collection('shops/${user.uid}/images');

        await images.add({'url': imageUrl});
      }
    } catch (e) {
      print('Error saving image URL to Firestore: $e');
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference reference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/$fileName');
      await reference.putFile(imageFile);
      String imageUrl = await reference.getDownloadURL();

      await saveImageToFirestore(imageUrl);

      setState(() {
        imageUrls.add(imageUrl);
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File selectedImage = File(image.path);
      await uploadImageToFirebase(selectedImage);
    }
  }

  Stream<List<String>> getImageUrlsStream() async* {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Stream<QuerySnapshot> snapshots = FirebaseFirestore.instance
            .collection('shops')
            .doc(user.uid)
            .collection('images')
            .snapshots();

        await for (QuerySnapshot querySnapshot in snapshots) {
          yield querySnapshot.docs.map((doc) => doc['url'] as String).toList();
        }
      } else {
        yield [];
      }
    } catch (e) {
      print('Error fetching image URLs from Firestore: $e');
      yield [];
    }
  }

  Future<void> deleteImage(String id, String imageUrlToDelete) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(imageUrlToDelete)
          .delete();

      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(user!.uid)
          .collection('images')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userType');

      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginInfo()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 135),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content:
                              const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => _logout(context),
                              child: const Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: _fetchShopDetailsFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                } else {
                  String imageUrl = '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var shopSnapshot = snapshot.data!;
                    tailorName = shopSnapshot['shopName'];
                    tailorLocation = shopSnapshot['city'];
                    tailorPhoneNumber = shopSnapshot['phoneNumber'];
                    imageUrl = shopSnapshot['profile_pic'];
                  }
                  return Center(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                height: 630,
                                width: 385,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25, top: 25),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: imageUrl.isNotEmpty
                                                    ? Image.network(
                                                        imageUrl,
                                                        width: 135,
                                                        height: 135,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Container(
                                                        width: 135,
                                                        height: 135,
                                                        color: Colors.grey,
                                                        child: const Icon(
                                                            Icons.image),
                                                      ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 35, left: 25),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tailorName,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 13),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      tailorLocation.replaceAll(
                                                          ' ', '\n'),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 18),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                        Icons.phone_outlined,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      tailorPhoneNumber,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const EditProfile(),
                                                          ),
                                                        );
                                                      },
                                                      child: const Icon(
                                                          Icons.edit,
                                                          size: 20),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Divider(
                                        color: Colors.red,
                                        thickness: .5,
                                      ),
                                    ),
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('shops')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('images')
                                          // .doc()
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (snapshot
                                            .data!.docs.isEmpty) {
                                          return Text('No images selected');
                                        } else {
                                          return Wrap(
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            children: List.generate(
                                              snapshot.data!.docs.length,
                                              (index) {
                                                DocumentSnapshot
                                                    shopImageSnapshot =
                                                    snapshot.data!.docs[index];
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      height: 115,
                                                      width: 115,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              2.5),
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            shopImageSnapshot[
                                                                'url'],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: IconButton(
                                                        icon:
                                                            Icon(Icons.delete),
                                                        onPressed: () =>
                                                            deleteImage(
                                                                shopImageSnapshot
                                                                    .id,
                                                                shopImageSnapshot[
                                                                    'url']),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: pickImage,
                                  child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 30))),
                              SizedBox(width: 7),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ReceivedRequestsPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child:
                                        const Icon(Icons.send_sharp, size: 30)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}

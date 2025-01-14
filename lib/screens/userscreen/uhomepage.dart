import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_connect/screens/LoginInfoScreen/logininfo.dart';
import 'package:tailors_connect/screens/userscreen/tailordetail.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<String>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
    _favoritesFuture = _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
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

  Future<List<String>> _loadFavorites() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      return favoritesSnapshot.docs.map((doc) => doc.id).toList();
    }
    return [];
  }

  void _addFavorite(String uid, String tailorId) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(tailorId)
        .set({});
  }

  void _removeFavorite(String uid, String tailorId) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(tailorId)
        .delete();
  }

  void _launchPhoneDialer(String phoneNumber) async {
    Uri phoneLaunchUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      throw 'Could not launch $phoneLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          margin: const EdgeInsets.only(top: 45),
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 60,
                  width: 300,
                  child: TextFormField(
                    controller: _searchController,
                    autocorrect: false,
                    autofillHints: const [],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search_outlined),
                      hintText: 'Search Keyword...',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFfdebea),
      body: Padding(
        padding: const EdgeInsets.only(top: 2, left: 10, right: 10, bottom: 65),
        child: FutureBuilder<List<String>>(
          future: _favoritesFuture,
          builder: (context, favoritesSnapshot) {
            if (!favoritesSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<String> favoriteTailors = favoritesSnapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('shops').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tailor found.'));
                } else {
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var tailorData = doc.data() as Map<String, dynamic>;
                    return tailorData['shopName']
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        tailorData['city'].toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var tailorData = filteredDocs[index];
                      final tailorId = tailorData.id;
                      final isFavorite = favoriteTailors.contains(tailorId);

                      return Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TailorDetailsPage(
                                      tailorData: tailorData,
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Container(
                                  height: 160,
                                  width: 360,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            tailorData['profile_pic'],
                                            width: 135,
                                            height: 135,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, left: 22),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tailorData['shopName'],
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Text(
                                                      '${tailorData['city'].split(' ').join('\n')}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _launchPhoneDialer(
                                                          tailorData[
                                                              'phoneNumber']);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        tailorData[
                                                            'phoneNumber'],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 20,
                              child: GestureDetector(
                                onTap: () async {
                                  final user = _auth.currentUser;
                                  if (user != null) {
                                    final uid = user.uid;
                                    setState(() {
                                      if (isFavorite) {
                                        favoriteTailors.remove(tailorId);
                                        _removeFavorite(uid, tailorId);
                                      } else {
                                        favoriteTailors.add(tailorId);
                                        _addFavorite(uid, tailorId);
                                      }
                                    });

                                    final snackBar = SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(
                                        isFavorite
                                            ? 'Removed from Favorites'
                                            : 'Added to Favorites',
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_outline_outlined,
                                    size: 30,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

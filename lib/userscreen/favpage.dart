import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> favoriteTailors = [];
  bool isLoading = true;
  Future<List<String>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites(); // Cache future result
  }

  Future<List<String>> _loadFavorites() async {
    final user = _auth.currentUser;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdebea),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no favorite tailors.'));
          } else {
            favoriteTailors = snapshot.data!;
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Favourites',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: favoriteTailors.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore
                              .collection('shops')
                              .doc(favoriteTailors[index])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(); // Return empty container while waiting
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                !snapshot.data!.exists) {
                              return Text('Tailor data not found.');
                            } else {
                              var tailorData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final tailorId = snapshot.data!.id;
                              final isFavorite =
                                  favoriteTailors.contains(tailorId);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 160,
                                      width: 390,
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
                                                top: 22, left: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tailorData['shopName'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 8),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 12),
                                                        child: Text(
                                                          '${tailorData['city'].split(' ').join('\n')}',
                                                          style:
                                                              const TextStyle(
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.phone_outlined,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 8),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          tailorData[
                                                              'phoneNumber'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    Positioned(
                                      bottom: 15,
                                      right: 15,
                                      child: GestureDetector(
                                        onTap: () {
                                          _toggleFavorite(tailorId, isFavorite);
                                        },
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_outline_outlined,
                                          size: 30,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _toggleFavorite(String tailorId, bool isFavorite) {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      if (isFavorite) {
        _removeFavorite(uid, tailorId);
      }
    }
  }

  void _removeFavorite(String uid, String tailorId) {
    setState(() {
      favoriteTailors.remove(tailorId);
    });

    _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(tailorId)
        .delete()
        .then((value) {
      final snackBar = const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Removed from Favorites'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}

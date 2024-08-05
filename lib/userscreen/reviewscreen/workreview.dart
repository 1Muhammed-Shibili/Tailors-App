import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WorksAndReviews extends StatefulWidget {
  const WorksAndReviews({super.key, required this.tailorId});
  final String tailorId;
  @override
  State<WorksAndReviews> createState() => _WorksAndReviewsState();
}

class _WorksAndReviewsState extends State<WorksAndReviews> {
  TextEditingController reviewController = TextEditingController();
  List<Review> reviews = [];
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('shops')
        .doc(widget.tailorId)
        .collection('images')
        .doc()
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                backgroundColor: const Color(0xFFfdebea),
                appBar: AppBar(
                  backgroundColor: const Color(0xFFfdebea),
                  elevation: 0,
                  centerTitle: true,
                  title: Row(
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
                        padding: EdgeInsets.only(left: 85),
                        child: Text(
                          'Works and reviews',
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  bottom: const TabBar(
                    indicatorColor: Colors.red,
                    labelColor: Colors.red,
                    tabs: [
                      Tab(text: 'Works', icon: Icon(Icons.image_outlined)),
                      Tab(text: 'Reviews', icon: Icon(Icons.reviews_outlined)),
                    ],
                  ),
                ),
                body: TabBarView(children: [
                  // Content for Tab 1
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('shops')
                        .doc(widget.tailorId)
                        .collection('images')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        print('Has data');
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot worksReviewsSnapshot =
                                snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                padding: const EdgeInsets.only(top: 20),
                                height: 400,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Image.network(
                                      worksReviewsSnapshot['url'],
                                      height: 360,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Text(
                        'data',
                        style: TextStyle(color: Colors.black),
                      );
                    },
                  ),
                  // Content for Tab 2
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: ReviewItem(tailorId: widget.tailorId),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            children: [
                              RatingBar.builder(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 40,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: reviewController,
                                decoration: const InputDecoration(
                                  labelText: 'Your Review',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              String userReview = reviewController.text;
                              MyUser userData = await getUserData();
                              Review newReview = Review(
                                username: userData.username,
                                imageUrl: userData.profilePicUrl,
                                text: userReview,
                                rating: _rating,
                              );

                              await FirebaseFirestore.instance
                                  .collection('shops')
                                  .doc(widget.tailorId)
                                  .collection('reviews')
                                  .add(newReview.toMap());

                              setState(() {
                                reviews.add(newReview);
                              });

                              reviewController.clear();
                            } catch (e) {
                              print('Error submitting review: $e');
                            }
                          },
                          child: Text('Submit Review'),
                        ),
                      ],
                    ),
                  ),
                ]))));
  }

  Future<MyUser> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return MyUser.fromSnapshot(userSnapshot);
      } else {
        throw Exception('User data not found in Firestore');
      }
    } else {
      throw Exception('User not authenticated');
    }
  }
}

class Review {
  final String username;
  final String imageUrl;
  final String text;
  final double rating;

  Review({
    required this.username,
    required this.imageUrl,
    required this.text,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'imageUrl': imageUrl,
      'text': text,
      'rating': rating,
    };
  }
}

class ReviewItem extends StatelessWidget {
  final String tailorId;

  const ReviewItem({Key? key, required this.tailorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shops')
          .doc(tailorId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        List<Review> reviews = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Review(
            username: data['username'],
            imageUrl: data['imageUrl'],
            text: data['text'],
            rating: data['rating'],
          );
        }).toList();
        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            Review review = reviews[index];
            return ListTile(
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(review.imageUrl),
                    radius: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.username,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              title: Text(review.text),
              subtitle: RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
              ),
            );
          },
        );
      },
    );
  }
}

class MyUser {
  final String username;
  final String profilePicUrl;

  MyUser({required this.username, required this.profilePicUrl});

  factory MyUser.fromSnapshot(DocumentSnapshot snapshot) {
    return MyUser(
      username: snapshot['username'],
      profilePicUrl: snapshot['profile_pic'],
    );
  }
}

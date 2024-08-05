import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SentRequestsPage extends StatelessWidget {
  const SentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFfdebea),
        body: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(
              child: Text(
                'Send Requets',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('senderUid',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No Requests Found'),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(request['message']),
                      subtitle:const Text('Status: Sent'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('requests')
                              .doc(request.id)
                              .delete()
                              .then((value) {
                            print('Message canceled successfully');
                          }).catchError((error) {
                            print('Failed to cancel message: $error');
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ]));
  }
}

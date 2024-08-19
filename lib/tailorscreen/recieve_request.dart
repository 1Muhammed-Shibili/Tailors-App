// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class TailorRequestsPage extends StatelessWidget {
//   const TailorRequestsPage({super.key});

//   Future<void> _updateRequestStatus(
//       String userId, String requestId, String newStatus) async {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('requests')
//         .doc(requestId)
//         .update({'status': newStatus});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String tailorId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       backgroundColor: const Color(0xFFfdebea),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 50),
//             child: Center(
//               child: Text(
//                 'Incoming Requests',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collectionGroup('requests')
//                   .where('tailorId', isEqualTo: tailorId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text('No Requests Found'),
//                   );
//                 } else {
//                   return ListView.builder(
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       var requestDoc = snapshot.data!.docs[index];
//                       var request = requestDoc.data() as Map<String, dynamic>;
//                       var userId = request['userId'];

//                       return FutureBuilder<DocumentSnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(userId)
//                             .get(),
//                         builder: (context, senderSnapshot) {
//                           if (senderSnapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           } else if (!senderSnapshot.hasData) {
//                             return const ListTile(
//                               title: Text('Error loading sender data'),
//                             );
//                           }

//                           var senderData = senderSnapshot.data!.data()
//                               as Map<String, dynamic>?;
//                           String senderName =
//                               senderData?['username'] ?? 'Unknown Sender';

//                           String status = request['status'] ?? 'sent';
//                           String statusText;
//                           Color statusColor;

//                           switch (status) {
//                             case 'accepted':
//                               statusText = 'Accepted';
//                               statusColor = Colors.green;
//                               break;
//                             case 'rejected':
//                               statusText = 'Rejected';
//                               statusColor = Colors.red;
//                               break;
//                             default:
//                               statusText = 'Pending';
//                               statusColor = Colors.orange;
//                               break;
//                           }

//                           return ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 12.0, horizontal: 20.0),
//                             title: Row(
//                               children: [
//                                 if (request['imageUrl'] != null &&
//                                     request['imageUrl'].isNotEmpty)
//                                   Container(
//                                     margin: const EdgeInsets.only(right: 16.0),
//                                     child: Image.network(
//                                       request['imageUrl'],
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         request['message'] ?? 'No message',
//                                         style: const TextStyle(fontSize: 16),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'From: $senderName',
//                                         style: const TextStyle(
//                                             fontSize: 14, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Text(
//                                   statusText,
//                                   style: TextStyle(
//                                       color: statusColor,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green),
//                                   onPressed: () {
//                                     _updateRequestStatus(
//                                             userId, requestDoc.id, 'accepted')
//                                         .then((_) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text('Request accepted'),
//                                         ),
//                                       );
//                                     });
//                                   },
//                                   child: const Text('Accept'),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red),
//                                   onPressed: () {
//                                     _updateRequestStatus(
//                                             userId, requestDoc.id, 'rejected')
//                                         .then((_) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text('Request rejected'),
//                                         ),
//                                       );
//                                     });
//                                   },
//                                   child: const Text('Reject'),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

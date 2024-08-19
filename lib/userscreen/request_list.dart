// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SentRequestsPage extends StatelessWidget {
//   const SentRequestsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFfdebea),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 50),
//             child: Center(
//               child: Text(
//                 'Sent Requests',
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
//                   .collection('users')
//                   .doc(FirebaseAuth.instance.currentUser!.uid)
//                   .collection('requests')
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
//                       var request = snapshot.data!.docs[index].data()
//                           as Map<String, dynamic>?;

//                       if (request == null) {
//                         return const ListTile(
//                           title: Text('Error loading request data'),
//                         );
//                       }

//                       String status = request.containsKey('status')
//                           ? request['status']
//                           : 'sent';
//                       String statusText;
//                       Color statusColor;

//                       switch (status) {
//                         case 'accepted':
//                           statusText = 'Accepted';
//                           statusColor = Colors.green;
//                           break;
//                         case 'rejected':
//                           statusText = 'Rejected';
//                           statusColor = Colors.red;
//                           break;
//                         default:
//                           statusText = 'Pending';
//                           statusColor = Colors.orange;
//                           break;
//                       }

//                       return FutureBuilder<DocumentSnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection('shops')
//                             .doc(request['tailorId'])
//                             .get(),
//                         builder: (context, tailorSnapshot) {
//                           if (tailorSnapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           } else if (!tailorSnapshot.hasData) {
//                             return const ListTile(
//                               title: Text('Error loading tailor data'),
//                             );
//                           }

//                           var tailorData = tailorSnapshot.data!.data()
//                               as Map<String, dynamic>?;
//                           String tailorName =
//                               tailorData?['shopName'] ?? 'Unknown Tailor';

//                           return ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 8.0, horizontal: 16.0),
//                             title: Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       if (request['imageUrl'] != null &&
//                                           request['imageUrl'].isNotEmpty)
//                                         Container(
//                                           margin:
//                                               const EdgeInsets.only(right: 8.0),
//                                           child: Image.network(
//                                             request['imageUrl'],
//                                             width: 50,
//                                             height: 50,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               request['message'] ??
//                                                   'No message',
//                                               style:
//                                                   const TextStyle(fontSize: 16),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             const SizedBox(height: 3),
//                                             Text(
//                                               '$tailorName',
//                                               style: const TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.grey),
//                                             ),
//                                             if (request['imageUrl'] == null ||
//                                                 request['imageUrl'].isEmpty)
//                                               const SizedBox(height: 5),
//                                           ],
//                                         ),
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
//                             trailing: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               onPressed: () {
//                                 FirebaseFirestore.instance
//                                     .collection('users')
//                                     .doc(FirebaseAuth.instance.currentUser!.uid)
//                                     .collection('requests')
//                                     .doc(snapshot.data!.docs[index].id)
//                                     .delete()
//                                     .then((value) {
//                                   print('Request canceled successfully');
//                                 }).catchError((error) {
//                                   print('Failed to cancel request: $error');
//                                 });
//                               },
//                               child: const Text('Cancel'),
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

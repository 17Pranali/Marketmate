// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:btech_project/frontend/Category_selection.dart';
// import 'package:btech_project/backend/welcomepage_firestoreservices.dart';

// class WelcomePage extends StatelessWidget {
//   final String userUid;
//   final FirestoreService _firestoreService = FirestoreService();

//   WelcomePage({Key? key, required this.userUid}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome'),
//         backgroundColor: Colors.teal,
//       ),
//       body: FutureBuilder<DocumentSnapshot?>(
//         future: _firestoreService.getUserData(userUid),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData ||
//               snapshot.data == null ||
//               !snapshot.data!.exists) {
//             return Center(child: Text('User not found.'));
//           }

//           var userData = snapshot.data!;
//           String firstName = userData['first_name'] ?? 'User';

//           return Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Welcome, $firstName!',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Ready to explore categories for your business?',
//                     style: TextStyle(fontSize: 18),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 40),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               CategorySelectionPage(userUid: userUid),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: Text(
//                       "Explore Categories",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

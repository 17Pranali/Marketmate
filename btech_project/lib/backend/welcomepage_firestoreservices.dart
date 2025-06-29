import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserData(String userUid) async {
    try {
      return await _db.collection('verified_users').doc(userUid).get();
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}

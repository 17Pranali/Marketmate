import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/material.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch existing business data
  Future<void> loadBusinessData(String userUid, String category,
      BuildContext context, Function setState) async {
    try {
      final querySnapshot = await _firestore
          .collection('business_categories')
          .where('userUid', isEqualTo: userUid)
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          // Set state to update the form fields
          // Populate the form fields
        });
      }
    } catch (e) {
      print('Error loading business data: $e');
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> uploadImage(File image) async {
    try {
      final storageRef = _storage
          .ref()
          .child('profile_pics/${DateTime.now().millisecondsSinceEpoch}');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Save business data to Firestore
  Future<void> saveBusinessData(
      Map<String, dynamic> businessData, String userUid) async {
    try {
      final existingDoc = await _firestore
          .collection('business_categories')
          .where('userUid', isEqualTo: userUid)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        await existingDoc.docs.first.reference.update(businessData);
      } else {
        await _firestore.collection('business_categories').add(businessData);
      }
    } catch (e) {
      print('Error saving business data: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:btech_project/frontend/signin_page.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Step 1: Verify MSME data and check if the user is already registered
  void verifyDetails(
    String firstName,
    String lastName,
    String gstin,
    String phone,
    String email,
    String aadhar,
    String password,
    BuildContext context,
    String language, // ✅ New parameter
  ) async {
    try {
      final verifiedEmailQuery = await _firestore
          .collection('verified_users')
          .where('email', isEqualTo: email)
          .get();

      if (verifiedEmailQuery.docs.isNotEmpty) {
        _showMessage(context, "This email is already verified. Please log in.");
        return;
      }

      final verifiedDetailsQuery = await _firestore
          .collection('verified_users')
          .where('first_name', isEqualTo: firstName)
          .where('last_name', isEqualTo: lastName)
          .where('gstin', isEqualTo: gstin)
          .get();

      if (verifiedDetailsQuery.docs.isNotEmpty) {
        _showMessage(
            context, "These details are already verified. Log in instead.");
        return;
      }

      final msmeQuery = await _firestore
          .collection('msme')
          .where('first_name', isEqualTo: firstName)
          .where('last_name', isEqualTo: lastName)
          .where('gstin', isEqualTo: gstin)
          .get();

      if (msmeQuery.docs.isNotEmpty) {
        // ✅ Pass language to next step
        _sendVerificationEmail(
          firstName,
          lastName,
          gstin,
          phone,
          email,
          aadhar,
          password,
          context,
          language,
        );
      } else {
        _storeUnverifiedUserData(
          firstName,
          lastName,
          gstin,
          phone,
          email,
          aadhar,
          context,
        );
      }
    } catch (e) {
      _showMessage(context, "An error occurred: $e");
    }
  }

  // Step 2: Send Verification Email
  void _sendVerificationEmail(
    String firstName,
    String lastName,
    String gstin,
    String phone,
    String email,
    String aadhar,
    String password,
    BuildContext context,
    String language, // ✅ Add language here too
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      _storeUserData(
        userCredential.user!.uid,
        firstName,
        lastName,
        gstin,
        phone,
        email,
        aadhar,
        context,
        language, // ✅ pass language
      );

      _showMessage(
          context, "Verification email sent! Please check your inbox.");
    } catch (e) {
      _showMessage(context, "Failed to send verification email: $e");
    }
  }

  // Function to show message and navigate to login page
  void _showMessageAndNavigate(
    BuildContext context,
    String message,
    String language, // ✅ Accept language here
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(language: language), // ✅ Use it
        ),
      );
    });
  }

  // Step 3: Store Verified User Data
  Future<void> _storeUserData(
    String uid,
    String firstName,
    String lastName,
    String gstin,
    String phone,
    String email,
    String aadhar,
    BuildContext context,
    String language, // ✅ Accept language
  ) async {
    await _firestore.collection('verified_users').doc(uid).set({
      'first_name': firstName,
      'last_name': lastName,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'aadhar': aadhar,
      'verified_at': Timestamp.now(),
    });

    _showMessageAndNavigate(context, "Account created successfully!", language);
  }

  // Step 4: Store Unverified User Data
  Future<void> _storeUnverifiedUserData(
    String firstName,
    String lastName,
    String gstin,
    String phone,
    String email,
    String aadhar,
    BuildContext context,
  ) async {
    await _firestore.collection('unverified_users').add({
      'first_name': firstName,
      'last_name': lastName,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'aadhar': aadhar,
      'created_at': Timestamp.now(),
    });

    _showMessage(context,
        "Details do not match MSME records. You are marked as unverified.");
  }

  // Message helper
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'package:btech_project/frontend/home_page.dart';
import 'package:btech_project/frontend/profile_creation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:btech_project/frontend/admin_dashboard.dart';

class SignInAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
    required String language,
  }) async {
    try {
      // Step 1: Check for Admin
      final adminQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminData = adminQuery.docs.first.data();
        final storedPassword = adminData['password'];

        if (password == storedPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
          return;
        } else {
          _showError(context, "Incorrect password. Please try again.");
          return;
        }
      }

      // Step 2: Sign in regular user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null && user.emailVerified) {
        final userUid = user.uid;

        // Step 3: Check if user is verified
        final verifiedUser =
            await _firestore.collection('verified_users').doc(userUid).get();

        if (!verifiedUser.exists) {
          _showError(context, "User is not verified.");
          return;
        }

        // Step 4: Check if profile exists
        final profileExists = await _doesProfileExist(userUid);

        if (profileExists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(language: language)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ProfileCreationPage(language: language)),
          );
        }
      } else {
        _showError(context, "Please verify your email before logging in.");
      }
    } catch (e) {
      _showError(context, "Failed to login: $e");
    }
  }

  // ✅ Helper method to check if profile exists
  Future<bool> _doesProfileExist(String userUid) async {
    final doc = await _firestore.collection('users').doc(userUid).get();
    return doc.exists;
  }

  Future<void> forgotPassword(String email, BuildContext context) async {
    try {
      final adminQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Admin accounts are not allowed to reset passwords here."),
          ),
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Password reset email sent! Please check your inbox to reset your password."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send password reset email: $e")),
      );
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

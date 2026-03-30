// lib/firebase auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_habit_coach/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // ✅ Discard credential — never access .user on it (PigeonUserDetails bug)
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;
      if (user == null) throw 'Registration failed. Please try again.';

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // ✅ Wrapped — rules may not propagate instantly right after signup
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());
      } catch (e) {
        debugPrint('Firestore user doc create error (non-fatal): $e');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Discard credential — never access .user on it (PigeonUserDetails bug)
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;
      if (user == null) throw 'Sign in failed. Please try again.';

      // ✅ lastLogin update is best-effort — permission-denied must NEVER
      // crash the login flow. Fully wrapped in try/catch.
      try {
        await _firestore.collection('users').doc(user.uid).set(
          {'lastLogin': Timestamp.fromDate(DateTime.now())},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('lastLogin update error (non-fatal): $e');
      }

      // ✅ Firestore user doc read is also best-effort
      try {
        final doc =
        await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) return UserModel.fromFirestore(doc);
      } catch (e) {
        debugPrint('Firestore user doc read error (non-fatal): $e');
      }

      // Always return a valid model from Firebase Auth data
      // even if Firestore is unreachable or rules block it
      return UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
      await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('getCurrentUserModel Firestore error (non-fatal): $e');
    }

    // Always return something — never leave the app stuck on splash
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
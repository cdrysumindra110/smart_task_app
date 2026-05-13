import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _pendingAuthMessage;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? consumePendingAuthMessage() {
    final message = _pendingAuthMessage;
    _pendingAuthMessage = null;
    return message;
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedEmail = email.trim();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password.trim(),
      );

      final synced = await _syncUserProfile(credential.user);
      await _auth.signOut();
      _pendingAuthMessage = synced
          ? 'Account created successfully. Please sign in.'
          : 'Account created. Please sign in. Profile sync to Firestore failed; check users rules.';
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (_isSignedInAs(normalizedEmail)) {
        await _auth.signOut();
        _pendingAuthMessage = 'Account created successfully. Please sign in.';
        notifyListeners();
        return null;
      }
      return _mapFirebaseError(e.code);
    } catch (_) {
      if (_isSignedInAs(normalizedEmail)) {
        await _auth.signOut();
        _pendingAuthMessage = 'Account created successfully. Please sign in.';
        notifyListeners();
        return null;
      }
      return 'Authentication failed. Please try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedEmail = email.trim();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password.trim(),
      );

      await _syncUserProfile(credential.user);
      _pendingAuthMessage = 'Signed in successfully.';
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (_isSignedInAs(normalizedEmail)) {
        _pendingAuthMessage = 'Signed in successfully.';
        notifyListeners();
        return null;
      }
      return _mapFirebaseError(e.code);
    } catch (_) {
      if (_isSignedInAs(normalizedEmail)) {
        _pendingAuthMessage = 'Signed in successfully.';
        notifyListeners();
        return null;
      }
      return 'Authentication failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  bool _isSignedInAs(String normalizedEmail) {
    final currentEmail = _auth.currentUser?.email?.trim().toLowerCase();
    return currentEmail != null && currentEmail == normalizedEmail;
  }

  Future<bool> _syncUserProfile(User? user) async {
    if (user == null) return false;

    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email or password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'channel-error':
        return 'Authentication setup issue detected. Please restart the app and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}

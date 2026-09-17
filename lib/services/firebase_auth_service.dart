import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with Email and Password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("SignUp Error: ${e.code}");
      }
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("SignIn Error: ${e.code}");
      }
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(googleProvider);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Google Sign In Error: ${e.code} - ${e.message}");
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign In General Error: $e");
      }
      rethrow;
    }
  }

  static final Map<String, String> _roleCache = {};

  // Sign out
  Future<void> signOut() async {
    _roleCache.clear();
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Save User Profile to Firestore — writes to both specified collection and primary 'users/{uid}'
  Future<void> saveUserProfile(String uid, Map<String, dynamic> userData, {String collection = 'users'}) async {
    try {
      final role = userData['role'] as String?;
      if (role != null) {
        _roleCache[uid] = role;
      }
      await _firestore.collection(collection).doc(uid).set(userData);
      if (collection != 'users') {
        await _firestore.collection('users').doc(uid).set(userData);
      }
    } catch (e) {
      if (kDebugMode) print("Firestore Save Error: $e");
      rethrow;
    }
  }

  // Fetch User Role from Firestore — checks cache, then farmers and shopkeepers collections
  Future<String?> getUserRole(String uid) async {
    if (_roleCache.containsKey(uid)) {
      return _roleCache[uid];
    }
    try {
      // Check 'farmers' collection first
      DocumentSnapshot doc = await _firestore.collection('farmers').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final role = (doc.data() as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          _roleCache[uid] = role;
          return role;
        }
      }
      // Then check 'shopkeepers' collection
      doc = await _firestore.collection('shopkeepers').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final role = (doc.data() as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          _roleCache[uid] = role;
          return role;
        }
      }
      // Fallback to old 'users' collection (for existing test accounts)
      doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final role = (doc.data() as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          _roleCache[uid] = role;
          return role;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Firestore Get Role Error: $e");
    }
    return null;
  }

  // Real Phone Auth (Scaffolding for UI to call)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<User?> signInWithPhoneCredential(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) print("Phone Auth Sign In Error: $e");
      rethrow;
    }
  }
}

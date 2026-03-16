import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
    
    
  // Send password reset email
  Future<void> resetPassword(String email) async {
    
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email.trim());
    
      await _auth.sendPasswordResetEmail(email: email.trim());
  
  }

  Future<User?> signup(String email, String password, String name) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;

    if (user != null) {
      await user.sendEmailVerification(); // Send verification email
      final uid = user.uid;
      await user.updateDisplayName(name);
      await user.reload();
      user = _auth.currentUser;

      try {
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
          'emailVerified': false, // Track verification status
        });
      } catch (e) {
        print('Error writing user data to Firestore: $e');
        throw 'Failed to save user info to database.';
      }

      // Sign out immediately after signup
      await _auth.signOut();
    }
    return null; // Return null to indicate account is not active yet
  } on FirebaseAuthException catch (e) {
    throw e.message ?? 'Signup failed';
  }
}

Future<User?> login(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await _auth.signOut();
      throw 'Please verify your email before logging in. A new verification email has been sent.';
    }
    return user;
  } on FirebaseAuthException catch (e) {
    throw e.message ?? 'Login failed';
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

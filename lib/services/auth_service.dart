import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'isOnline': true,
        'lastSeen': DateTime.now().toIso8601String(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Google sign in cancelled';

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        final user = UserModel(
          uid: uid,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          phone: '',
          isOnline: true,
          lastSeen: DateTime.now(),
        );
        await _firestore.collection('users').doc(uid).set(user.toMap());
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return e.toString();
    }
  }
  Future<void> logout() async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'isOnline': false,
        'lastSeen': DateTime.now().toIso8601String(),
      });
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      await _auth.signOut();
    }
  }
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
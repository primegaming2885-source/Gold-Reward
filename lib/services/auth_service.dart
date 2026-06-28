import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _auth.signInWithCredential(credential);
      await _createOrUpdateUser(userCredential.user!);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential?> verifyOTP(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential =
        await _auth.signInWithCredential(credential);
    await _createOrUpdateUser(userCredential.user!);
    return userCredential;
  }

  Future<void> _createOrUpdateUser(User user) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        phone: user.phoneNumber ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        coins: 0,
        totalAdsWatched: 0,
        totalQuizCorrect: 0,
        totalWithdrawn: 0,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await docRef.set(newUser.toMap());
    } else {
      await docRef.update({
        'lastActive': Timestamp.now(),
        if (user.displayName != null &&
            user.displayName!.isNotEmpty)
          'name': user.displayName,
        if (user.photoURL != null)
          'photoUrl': user.photoURL,
      });
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> streamUserData(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) =>
            doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  bool isAdmin(String? email) {
    return email == AppConstants.adminEmail;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _googleSignIn = GoogleSignIn();

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with Google
  static Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    return _ensureUserDocument(user);
  }

  /// Sign in with email & password
  static Future<UserModel?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUser(credential.user!.uid);
  }

  /// Register with email & password
  static Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);
    return _ensureUserDocument(credential.user!);
  }

  /// Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Ensure Firestore user document exists (create if first login)
  static Future<UserModel> _ensureUserDocument(User user) async {
    final docRef = _firestore.collection(AppConstants.colUsers).doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'SDG Champion',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        joinedAt: DateTime.now(),
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    }

    return UserModel.fromFirestore(doc);
  }

  static Future<UserModel?> _getUser(String uid) async {
    final doc = await _firestore.collection(AppConstants.colUsers).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}

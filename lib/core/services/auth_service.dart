import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  // Use the same DB configuration as DatabaseService
  static final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://kitahack2026-f1f3e-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

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
  static Future<UserModel?> signInWithEmail(
      String email, String password) async {
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
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  /// Ensure User document exists in RTDB
  static Future<UserModel> _ensureUserDocument(User user) async {
    final ref = _db.child(AppConstants.colUsers).child(user.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'SDG Champion',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        joinedAt: DateTime.now(),
      );
      await ref.set(newUser.toFirestore());
      return newUser;
    }

    return UserModel.fromMap(snapshot.value as Map, user.uid);
  }

  static Future<UserModel?> _getUser(String uid) async {
    final snapshot = await _db.child(AppConstants.colUsers).child(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(snapshot.value as Map, uid);
  }
}

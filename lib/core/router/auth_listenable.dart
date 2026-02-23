import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A [Listenable] that notifies listeners when the [FirebaseAuth] state changes.
/// This allows [GoRouter] to re-evaluate its redirects automatically.
class AuthListenable extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  AuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

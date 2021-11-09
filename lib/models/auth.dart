import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

class Auth {
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    final User user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    return uid;
  }
}

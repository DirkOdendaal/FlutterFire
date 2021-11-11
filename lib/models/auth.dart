import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth firebaseAuthIns = FirebaseAuth.instance;
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    await firebaseAuthIns.signInWithEmailAndPassword(
        email: email, password: password);
    final User user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    return uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    await firebaseAuthIns.createUserWithEmailAndPassword(
        email: email, password: password);
    final User user = firebaseAuthIns.currentUser!;
    final uid = user.uid;
    return uid;
  }

  Future<String> currentUser() async {
    String finalUser = "";
    if (firebaseAuthIns.currentUser != null) {
      final user = firebaseAuthIns.currentUser!;
      finalUser = user.uid;
    }
    return finalUser;
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
}

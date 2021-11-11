import 'package:cloud/models/auth_provider.dart';
import 'package:cloud/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud/pages/login_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootePageState createState() => _RootePageState();
}

enum AuthStat { notSignedIn, signedIn }

class _RootePageState extends State<RootPage> {
  AuthStat _authstat = AuthStat.notSignedIn;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context)!.auth;
    auth!.currentUser().then((value) {
      setState(() {
        _authstat = value == "" ? AuthStat.notSignedIn : AuthStat.signedIn;
        print(_authstat);
      });
    });
  }

  void _signedIn() {
    setState(() {
      _authstat = AuthStat.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      _authstat = AuthStat.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authstat) {
      case AuthStat.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStat.signedIn:
        return HomePage(onSignedOut: _signedOut);
    }
  }
}

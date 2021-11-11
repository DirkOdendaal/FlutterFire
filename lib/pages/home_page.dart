import 'dart:js';

import 'package:flutter/material.dart';
import 'package:cloud/models/auth.dart';
import 'package:cloud/models/auth_provider.dart';

class HomePage extends StatelessWidget {
  HomePage({required this.onSignedOut});

  final VoidCallback onSignedOut;

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context)!.auth;
      await auth!.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Data"),
      ),
      body: Container(
        child: const Center(
            child: Text(
          "Welcome",
          style: TextStyle(fontSize: 30),
        )),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("Header")),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                _signOut(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

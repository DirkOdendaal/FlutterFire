import 'package:flutter/material.dart';

class DatabaseRead extends StatefulWidget {
  const DatabaseRead({Key? key}) : super(key: key);

  @override
  _DatabseReadState createState() => _DatabseReadState();
}

class _DatabseReadState extends State<DatabaseRead> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Read"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}

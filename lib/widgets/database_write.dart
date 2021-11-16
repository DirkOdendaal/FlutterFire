import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseWrite extends StatefulWidget {
  const DatabaseWrite({Key? key}) : super(key: key);

  @override
  _DatabaseWriteState createState() => _DatabaseWriteState();
}

class _DatabaseWriteState extends State<DatabaseWrite> {
  final database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    final photos = database.child('photos/');

    return Scaffold(
      appBar: AppBar(
        title: Text("Database Write"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    try {
                      await photos.set({
                        "description": "Image Name",
                        "url": "Image Url",
                        "dateCreated": "Date and Time"
                      }).then((_) => print("Uploaded data"));
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text("Write Stuff")),
            ],
          ),
        ),
      ),
    );
  }
}

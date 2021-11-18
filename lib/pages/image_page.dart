import 'package:cloud/models/firebase_file.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud/classes/firebase_api.dart';

class ImagePage extends StatelessWidget {
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: () async {
                _launchURL(file.url);
              },
              icon: const Icon(Icons.download_rounded)),
          IconButton(
              onPressed: () {
                // FirebaseAPI.deleteImage(file);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever)),
        ],
      ),
      body: Image.network(
        file.url,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  void _launchURL(final urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }
}

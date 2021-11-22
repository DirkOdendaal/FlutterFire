import 'package:cloud/classes/auth.dart';
import 'package:cloud/classes/firebase_api.dart';
import 'package:cloud/models/firebase_file.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImagePage extends StatefulWidget {
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class ImageNameValidator {
  static String? validate(String value) {
    return value == "" ? "New Name Required" : null;
  }
}

enum Formtype { view, edit }

class _ImagePageState extends State<ImagePage> {
  String _newImageName = "";
  final _formKey = GlobalKey<FormState>();
  Formtype _formType = Formtype.view;

  bool baseState = true;
  @override
  Widget build(BuildContext context) {
    return baseState ? baseEntry(context) : editState(context);
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        // var auth = AuthProvider.of(context)!.auth;
        // if (_formType == Formtype.login) {
        //   await auth!.signInWithEmailAndPassword(_email, _password);
        // } else {
        //   await auth!.createUserWithEmailAndPassword(_email, _password);
        // }
      } catch (e) {
        print('Login Error $e');
        // Handle errors here
      }
    }
  }

  void moveToEdita() {
    // form
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Scaffold baseEntry(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                baseState = false;
                setState(() {});
              },
              icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: () async {
                _launchURL(widget.file.url);
              },
              icon: const Icon(Icons.download_rounded)),
          IconButton(
              onPressed: () {
                FirebaseAPI.deleteImage(widget.file.id, Auth().userUIDret());
                FirebaseAPI.deleteImageStorage(widget.file.path);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever)),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              widget.file.url,
              fit: BoxFit.contain,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Image Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(widget.file.name),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Date Created",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(widget.file.dateCreated),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Date Modified",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(widget.file.dateModified),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _launchURL(final urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }

  Widget editState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                // FirebaseAPI.updateCurrentImage(file, currentUser)
              },
              icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              widget.file.url,
              fit: BoxFit.contain,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Edit Image Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "New Image Name"),
                          onSaved: (value) => _newImageName = value!,
                          validator: (value) =>
                              ImageNameValidator.validate(value!),
                        ),
                      ),
                      width: 150,
                      height: 50,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

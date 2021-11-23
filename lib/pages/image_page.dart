import 'package:cloud/classes/auth.dart';
import 'package:cloud/classes/firebase_api.dart';
import 'package:cloud/models/firebase_file.dart';
import 'package:cloud/models/user.dart';
import 'package:cloud/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImagePage extends StatefulWidget {
  final String currentFolder;
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file, required this.currentFolder})
      : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

enum Formtype { edit, view, search }

class ImageNameValidator {
  static String? validate(String value) {
    return value == "" ? "New Name Required" : null;
  }
}

class _ImagePageState extends State<ImagePage> {
  late Future<List<User>?> users;
  late String currentUser;
  String _newImageName = "";
  final _formKey = GlobalKey<FormState>();
  Formtype _formType = Formtype.view;

  bool baseState = true;
  @override
  Widget build(BuildContext context) {
    if (_formType == Formtype.edit) {
      return editState(context);
    } else {
      return baseEntry();
    }
  }

  void setUserUID() {
    currentUser = Auth().userUIDret();
  }

  @override
  void initState() {
    setUserUID();
    super.initState();
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        await FirebaseAPI.updateCurrentImage(
            _newImageName, currentUser, widget.file.id, widget.currentFolder);
        // moveToBase(); //Navigate back to current file but get new ref to file.
        Navigator.pop(context);
      } catch (e) {
        _displayTextInputDialog(context, 2, "Edit Error $e");
      }
    }
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, int newState, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Alert(
            meassage: message,
            alertState: newState,
          );
        });
  }

  void moveToEditState() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.edit;
    });
  }

  void moveToBase() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.view;
    });
  }

  void moveToSearch() {
    users = FirebaseAPI.getUsers();
    print(users);

    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.search;
    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  AppBar buildAppBar() {
    if (_formType == Formtype.search) {
      return AppBar(
        leading: const Icon(Icons.search),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), hintText: "Search ..."),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                moveToBase();
              },
              icon: const Icon(Icons.cancel))
        ],
      );
    } else {
      return AppBar(
        actions: [
          IconButton(
              onPressed: () {
                moveToEditState();
              },
              icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: () {
                moveToSearch();
              },
              icon: const Icon(Icons.share_outlined)),
          IconButton(
              onPressed: () async {
                _launchURL(widget.file.url);
              },
              icon: const Icon(Icons.download_rounded)),
          IconButton(
              onPressed: () {
                FirebaseAPI.deleteImage(
                    widget.file.id, currentUser, widget.currentFolder);
                // FirebaseAPI.deleteImageStorage(widget.file.path);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever)),
        ],
      );
    }
  }

  Widget baseEntry() {
    String fileName = "";
    if (widget.file.name.lastIndexOf(' | ') != -1) {
      fileName =
          widget.file.name.substring(widget.file.name.lastIndexOf(' | ') + 3);
    } else {
      fileName = widget.file.name;
    }
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Image.network(
                widget.file.url,
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
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
                        Text(fileName),
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
                ),
              ),
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
                validateAndSubmit();
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
                    SizedBox(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "New Image Name"),
                          onSaved: (value) =>
                              _newImageName = value! + widget.file.extention,
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

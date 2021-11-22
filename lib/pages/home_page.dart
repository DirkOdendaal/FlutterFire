import 'dart:async';
import 'dart:typed_data';
import 'package:cloud/classes/auth.dart';
import 'package:cloud/classes/firebase_api.dart';
import 'package:cloud/widgets/folder_line_grid.dart';
import 'package:cloud/widgets/photos_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud/classes/auth_provider.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UploadTask? task;
  late String currentUser;
  final TextEditingController _c = TextEditingController();
  @override
  void initState() {
    super.initState();

    setUserUID();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void setUserUID() {
    currentUser = Auth().userUIDret();
  }

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context)!.auth;
      await auth!.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Folder Name'),
          content: TextField(
            controller: _c,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Create Folder'),
              onPressed: () {
                FirebaseAPI.createFolder(_c.text, currentUser);
                _c.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future selectFile() async {
    try {
      Uint8List? fileBytes;
      String fileName = "";
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
      if (result != null) {
        if (result.files.length > 1) {
          for (var element in result.files) {
            String guid = Uuid().v1();
            fileBytes = element.bytes;
            fileName = "$guid | ${element.name}";
            uploadFile(fileBytes, fileName);
          }
        } else {
          String guid = Uuid().v1();

          fileBytes = result.files.first.bytes;
          fileName =
              "$guid | ${result.files.first.name}"; //Change File name selected to GUID to upload and keep file names in storage unique
        }

        uploadFile(fileBytes, fileName);
      }
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile(Uint8List? photo, String name) async {
    if (photo == null) return;
    final destination = 'photo/$name';

    task = FirebaseAPI.uploadBytes(destination, photo);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final indexOfPoint = name.lastIndexOf(".");
    final extention = name.substring(indexOfPoint);

    try {
      final photoRecord = <String, dynamic>{
        'path': destination,
        'imageName': name,
        'url': downloadUrl,
        'extention': extention,
        'dateCreated': DateTime.now().toIso8601String(),
        'dateModified': DateTime.now().toIso8601String()
      };

      //move to api
      //
      FirebaseAPI.pushPhotoToDatabase(photoRecord, currentUser);
    } catch (e) {
      print(e); //Create alerts for these.
    }
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapsot) {
          if (snapsot.hasData) {
            final snap = snapsot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Text(
                "$percentage %"); //Changes Upload Status to alert same as errors.
          } else {
            return Container();
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Data"),
        actions: <Widget>[
          task != null ? buildUploadStatus(task!) : Container(),
        ],
      ),
      body: Column(children: [
        FolderBar(currentUser: currentUser),
        Expanded(child: PictureGrid(currentUser: currentUser))
      ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("Header")),
            ListTile(
              title: const Text("Upload Image"),
              leading: const Icon(Icons.upload_rounded),
              onTap: () {
                selectFile();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Create Folder"),
              leading: const Icon(Icons.create_new_folder),
              onTap: () {
                _displayTextInputDialog(context);
              },
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout_rounded),
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

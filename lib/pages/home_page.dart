import 'dart:async';
import 'dart:typed_data';
import 'package:cloud/classes/auth.dart';
import 'package:cloud/classes/firebase_api.dart';
import 'package:cloud/widgets/alert_dialog.dart';
import 'package:cloud/widgets/folder_line_grid.dart';
import 'package:cloud/widgets/photos_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud/classes/auth_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  static _HomePageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();
}

class _HomePageState extends State<HomePage> {
  UploadTask? task;
  String currentFolder = "root";
  late String currentUser;
  late User user;
  @override
  void initState() {
    super.initState();

    setUserUID();
  }

  String getCurrentFolder() {
    return currentFolder;
  }

  void setCurrentFolder(String folder) {
    currentFolder = folder;
    setState(() {});
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
      _displayTextInputDialog(context, 2, "Logout Error $e");
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

  Future selectFile() async {
    try {
      Uint8List? fileBytes;
      String fileName = "";
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
      if (result != null) {
        if (result.files.length > 1) {
          for (var element in result.files) {
            String guid = const Uuid().v1();
            fileBytes = element.bytes;
            fileName = "$guid | ${element.name}";
            uploadFile(fileBytes, fileName);
          }
        } else {
          String guid = const Uuid().v1();

          fileBytes = result.files.first.bytes;
          fileName = "$guid | ${result.files.first.name}";
        }

        uploadFile(fileBytes, fileName);
      }
    } catch (e) {
      _displayTextInputDialog(context, 2, "Select File Error $e");
    }
  }

  Future uploadFile(Uint8List? photo, String name) async {
    if (photo == null) return;
    final destination = 'photo/$name';

    task = FirebaseAPI.uploadBytes(destination, photo);
    setState(() {});

    if (task == null) return;
    setState(() {});

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

      FirebaseAPI.pushPhotoToDatabase(photoRecord, currentUser, currentFolder);
    } catch (e) {
      _displayTextInputDialog(context, 2, "Upload To Database Error $e");
    }
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapsot) {
          if (snapsot.hasData) {
            final snap = snapsot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Center(
              child: Text("$percentage %"),
            );
          } else {
            return Container();
          }
        },
      );

  Widget header() {
    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();

    return StreamBuilder<Object>(
        stream: database.child('usersList/$currentUser').onValue,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasData) {
                final snapDataEvent = snapshot.data as Event;
                final dataEventValues = snapDataEvent.snapshot.value;
                if (dataEventValues != null) {
                  user = User(
                      email: dataEventValues["email"],
                      uid: currentUser,
                      username: dataEventValues["username"]);
                  return UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage("images/default_user.jpg"),
                    ),
                    accountEmail: Text(user.email),
                    accountName: Text(
                      user.username,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                  );
                } else {
                  print("Snapshot has no data");
                  return Container();
                }
              } else {
                print("Snapshot has no data");
                return Container();
              }
          }
        });
  }

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
        Expanded(
            child: PictureGrid(
          currentUser: currentUser,
          currentFolder: currentFolder,
        ))
      ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            header(),
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
              onTap: () async {
                await _displayTextInputDialog(
                  context,
                  3,
                  "Create Folder",
                );
                Navigator.pop(context);
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

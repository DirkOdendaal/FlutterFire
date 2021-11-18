import 'dart:async';
import 'dart:typed_data';
import 'package:cloud/classes/auth.dart';
import 'package:cloud/classes/firebase_api.dart';
import 'package:cloud/models/firebase_file.dart';
import 'package:cloud/pages/image_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud/classes/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FirebaseFile>> fileList; //This is for Realtime Database
  late Future<List<FirebaseFile>> futureFiles; //This is for Storage
  UploadTask? task;
  late String currentUser;
  late StreamSubscription _currentUserCollectionStream;

  @override
  void initState() {
    super.initState();
    setUserUID();
    // futureFiles = FirebaseAPI.listAll('photos/');
    _activateListeners();
  }

  @override
  void deactivate() {
    _currentUserCollectionStream.cancel();
    super.deactivate();
  }

  Future<void> _activateListeners() async {
    _currentUserCollectionStream = setRecordValueChangedListener(currentUser);
  }

  StreamSubscription setRecordValueChangedListener(String currentUser) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();

    return database.child('users/$currentUser/photos').onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value);
      fileList = data
          .map((key, value) {
            final name = value["imageName"] as String;
            final date = value["dateCreated"] as String;
            final url = value["url"] as String;
            final file = FirebaseFile(name: name, dateCreated: date, url: url);
            return MapEntry(key, file);
          })
          .values
          .toList() as Future<List<FirebaseFile>>;
    });
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

  Future selectFile() async {
    try {
      //Check Into Uploading Multiple Files now.
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first
            .name; //Change File name selected to GUID to upload and keep file names in storage unique

        uploadFile(fileBytes, fileName);
      }
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile(Uint8List? photo, String name) async {
    if (photo == null) return;
    final destination = 'photos/$name';

    task = FirebaseAPI.uploadBytes(destination, photo);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    try {
      final photoRecord = <String, dynamic>{
        'imageName': name,
        'url': downloadUrl,
        'dateCreated': DateTime.now().toIso8601String()
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

  Widget buildGrid(BuildContext context, FirebaseFile file) => Draggable(
        child: GridTile(
          child: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: Image.network(file.url),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ImagePage(file: file))),
          ),
        ),
        feedback: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset('assets/images/placeholder.png'),
            ],
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          width: 48,
          height: 48,
        ),
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
      body: FutureBuilder<List<FirebaseFile>>(
          future: fileList,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Some Errors"),
                  );
                } else {
                  final files = snapshot.data;

                  return GridView.builder(
                      itemCount: files!.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 20,
                              childAspectRatio: 3 / 2,
                              mainAxisSpacing: 20),
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return buildGrid(context, file);
                      });
                }
            }
          }),
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

import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud/models/firebase_file.dart';

class FirebaseAPI {
  static Future<List<String>> _getDownloadUrls(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException {
      return null;
    }
  }

  // static Future<void> deleteImage(FirebaseFile file) async {
  //   final ref = file.ref;
  //   return ref.delete();
  // }

  static Future<void> pushPhotoToDatabase(
      Map<String, dynamic> record, String currentUser) async {
    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    final childNode = database.child('users/$currentUser/photos');
    await childNode.push().set(record);
  }

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();
    final urls = await _getDownloadUrls(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(
              name: name,
              url: url,
              dateCreated: DateTime.now().toIso8601String());
          return MapEntry(index, file);
        })
        .values
        .toList();
  }
}

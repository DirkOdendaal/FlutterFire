import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud/models/firebase_file.dart';

class FirebaseAPI {
  static Future<List<String>> _getDownloadUrls(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
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
          final file = FirebaseFile(name: name, ref: ref, url: url);
          return MapEntry(index, file);
        })
        .values
        .toList();
  }
}

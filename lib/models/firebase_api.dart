import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAPI {
  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    final storageRef =
        _storage.ref().child('journal_images/${image.path.split('/').last}');
    final uploadTask = await storageRef.putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }
}

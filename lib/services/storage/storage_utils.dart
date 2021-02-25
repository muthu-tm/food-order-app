import 'package:firebase_storage/firebase_storage.dart';

class StorageUtils {
  static Future<bool> removeFile(String fileURL) async {
    try {
      await FirebaseStorage.instance.refFromURL(fileURL).delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }
}

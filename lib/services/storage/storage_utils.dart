import 'package:firebase_storage/firebase_storage.dart';

class StorageUtils {
  Future<bool> removeFile(String fileURL) async {
    try {
      StorageReference reference =
          await FirebaseStorage.instance.getReferenceFromUrl(fileURL);

      await reference.delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static Future<String> getVideoStoragePath() async {
    if (Platform.isAndroid) {
      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access external storage');
      }

      // Create a 'Videos' directory in the app's external storage
      final videoDir = Directory('${directory.path}/Videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      return videoDir.path;
    } else {
      throw Exception('Platform not supported');
    }
  }
} 
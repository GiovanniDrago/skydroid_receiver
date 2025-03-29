import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        // For Android 13 and above
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        return statuses.values.every((status) => status.isGranted);
      } else {
        // For Android 12 and below
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
        return statuses.values.every((status) => status.isGranted);
      }
    }
    return true;
  }

  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  static Future<bool> requestStorageAndAudioPermission() async {
    bool hasStoragePermission = await requestStoragePermission();
    bool hasAudioPermission = await Permission.microphone.request().isGranted;
    return hasStoragePermission && hasAudioPermission;
  }
}

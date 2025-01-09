import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

import 'permission_utils.dart';

class CaptureVideo {
  static Future<void> captureVideo(
      context, UVCCameraController cameraController) async {
    try {
      // Check permission first
      if (!await PermissionUtils.requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      // Capture the frame and get the saved path
      final String? savedPath = await cameraController.captureVideo();

      if (savedPath != null) {
        // Show success message with the actual path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved to: $savedPath')),
        );
      } else {
        // Handle case where no path was returned
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to capture video: No path returned')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture video: $e')),
      );
    }
  }
}

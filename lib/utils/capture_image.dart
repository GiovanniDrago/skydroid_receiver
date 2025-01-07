import 'package:flutter/material.dart';

import 'permission_utils.dart';

class CaptureImage {
  static Future<void> captureImage(context, cameraController) async {
    try {
      // Check permission first
      if (!await PermissionUtils.requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      // Capture the frame and get the saved path
      final String? savedPath = await cameraController?.takePicture();

      if (savedPath != null) {
        // Show success message with the actual path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $savedPath')),
        );
      } else {
        // Handle case where no path was returned
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to capture image: No path returned')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }
}

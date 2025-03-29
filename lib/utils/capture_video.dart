import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

import 'permission_utils.dart';

class CaptureVideo {
  // Private constructor
  CaptureVideo._();

  // Singleton instance
  static final CaptureVideo _instance = CaptureVideo._();

  // Getter for the instance
  static CaptureVideo get instance => _instance;

  // Path where the video is saved
  String? _savedPath;

  // Getter for the saved path
  String? get savedPath => _savedPath;

  // Path where the video is saved
  bool _isRecording = false;

  // Getter for the saved path
  bool get isRecording => _isRecording;

  Future<void> captureVideo(
      context, UVCCameraController cameraController) async {
    try {
      // Check permission first
      if (!await PermissionUtils.requestStorageAndAudioPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      // Capture the frame and get the saved path
      if (!_isRecording) {
        _isRecording = true;
        await cameraController.captureVideo().then((videoPath) {
          _savedPath = videoPath;
          if (_savedPath != null) {
            // Show success message with the actual path
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video saved to: $_savedPath')),
            );
          } else {
            // Handle case where no path was returned
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed to capture video: No path returned')),
            );
          }
        });

        return;
      } else {
        _isRecording = false;
        cameraController.captureVideo();
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture video: $e')),
      );
    }
  }
}

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody>
    with SingleTickerProviderStateMixin {
  UVCCameraController? cameraController;
  bool isMenuOpen = false;
  bool isAnimating = false; // Add this flag
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    cameraController = UVCCameraController();
    cameraController?.msgCallback = (state) {};
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: isMenuOpen ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Clean up
    super.dispose();
  }

  // Add this method to handle menu toggle
  void _handleMenuToggle() {
    if (isAnimating) return; // Prevent multiple clicks during animation

    setState(() {
      isMenuOpen = !isMenuOpen;
      isAnimating = true; // Start animation

      if (isMenuOpen) {
        _animationController.forward().whenComplete(() {
          setState(() => isAnimating = false); // Animation complete
        });
      } else {
        _animationController.reverse().whenComplete(() {
          setState(() => isAnimating = false); // Animation complete
        });
      }
    });
  }

  Future<bool> _requestPermission() async {
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

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  // Add method to capture and save image
  Future<void> _captureImage() async {
    try {
      // Check permission first
      if (!await _requestPermission()) {
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UVCCameraView(
                    cameraController: cameraController!,
                    width: screenWidth * 1.2,
                    height: screenWidth),
              ],
            ),
          ),
          if (isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _handleMenuToggle,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isMenuOpen) ...[
            FloatingActionButton(
              heroTag: "btnScreen", // Unique tags needed for multiple FABs
              mini: true,
              child: const Icon(Icons.photo_camera),
              onPressed: () {
                // Photo capture logic
                _captureImage();
                _handleMenuToggle();
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "btnVideo",
              mini: true,
              child: const Icon(Icons.videocam),
              onPressed: () {
                // Video recording logic
                _handleMenuToggle();
              },
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "btnMain",
            child: AnimatedIcon(
                icon: AnimatedIcons.menu_close, progress: _animationController),
            onPressed: () {
              setState(() {
                isMenuOpen = !isMenuOpen;
                if (isMenuOpen) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

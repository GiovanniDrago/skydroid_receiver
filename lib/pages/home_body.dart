import 'package:flutter/material.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';
import 'package:skydroid_receiver/utils/capture_video.dart';

import '../utils/capture_image.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with TickerProviderStateMixin {
  UVCCameraController? cameraController;
  bool isMenuOpen = false;
  bool isAnimating = false;
  bool isRecording = false;
  late AnimationController _animationController;
  late AnimationController _recordingAnimationController;

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
    _recordingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: isRecording ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Clean up
    _recordingAnimationController.dispose(); // Clean up
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
                CaptureImage.captureImage(context, cameraController);
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "btnVideo",
              mini: true,
              child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _recordingAnimationController),
              onPressed: () {
                setState(() {
                  isRecording = !isRecording;
                  if (isRecording) {
                    _recordingAnimationController.forward().whenComplete(() {
                      setState(() => isAnimating = false); // Animation complete
                    });
                  } else {
                    _recordingAnimationController.reverse().whenComplete(() {
                      setState(() => isAnimating = false); // Animation complete
                    });
                  }
                  CaptureVideo captureVideo = CaptureVideo.instance;
                  captureVideo.captureVideo(context, cameraController!);
                });
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

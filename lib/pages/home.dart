import 'package:flutter/material.dart';
import 'package:skydroid_receiver/utils/uvccamera_devices_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: UvcCameraDevicesScreen(),
    );
  }
}

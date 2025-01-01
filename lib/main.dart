import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skydroid_receiver/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MaterialApp(routes: {
      '/': (context) => const Home(),
    }));
  });
}

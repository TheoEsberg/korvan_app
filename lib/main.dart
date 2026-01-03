import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/korvan_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔒 Force portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KorvanApp());
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.activityRecognition.request();
  runApp(const DataUsageApp());
}

class DataUsageApp extends StatelessWidget {
  const DataUsageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: const HomeScreen(),
    );
  }
}
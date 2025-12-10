import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_app/screens/home_screen.dart';

import 'constants/storage_key.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Open the box and get reference to it
  final appKeyBox = await Hive.openBox('appKey');

  // Store the value in the box
  appKeyBox.put('apiKey', StorageKeys.apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'New App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // FIXED LINE
      ),
      home: const HomeScreen(),
    );
  }
}
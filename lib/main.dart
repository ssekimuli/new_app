import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/screens/home_screen.dart';
import 'package:new_app/services/hive_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.init();
  } catch (e) {
    print('Error initializing Hive: $e');
  }
  

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
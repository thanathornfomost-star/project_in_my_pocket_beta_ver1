import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/auth_gate.dart';
import 'firebase_options.dart'; // ไฟล์ที่ได้จาก FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project in My Pocket',
      theme: ThemeData(
        primarySwatch: Colors.blue, // สามารถเปลี่ยนสีธีมได้ตามต้องการ
      ),
      home: const AuthGate(),
    );
  }
}

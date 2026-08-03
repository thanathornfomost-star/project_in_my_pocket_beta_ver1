import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/splash_screen.dart';
import 'firebase_options.dart'; // ไฟล์ที่ได้จาก FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // เมื่อแอปกลับมาทำงาน ให้ไปที่ SplashScreen
      // การทำเช่นนี้จะล้างหน้าจอเก่าทั้งหมดออก
      _navigatorKey.currentState?.pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SplashScreen(),
          transitionDuration: const Duration(seconds: 0),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Project in My Pocket',
      theme: ThemeData(
        primarySwatch: Colors.blue, // สามารถเปลี่ยนสีธีมได้ตามต้องการ
      ),
      home: const SplashScreen(),
    );
  }
}

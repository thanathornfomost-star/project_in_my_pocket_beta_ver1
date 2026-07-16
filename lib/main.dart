import 'package:flutter/material.dart';
// Use a relative import to refer to the local screen file inside the `lib` folder.
import 'screen/splash_screen.dart';

// ย้าย AppColors มาไว้ที่นี่เพื่อการจัดการ Theme ที่ดีขึ้น
class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFEF4444);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 1. กำหนด Theme หลักของแอปพลิเคชัน
      theme: ThemeData(
        // 2. กำหนดสีหลัก (Primary Color) ให้เป็นสีฟ้า
        // ทุก Widget ที่เรียกใช้ Theme.of(context).primaryColor จะได้สีนี้ไป
        primaryColor: AppColors.primary,
        // 3. (แนะนำ) กำหนดสีให้กับ ElevatedButton โดยตรงเพื่อให้ปุ่มเป็นสีฟ้าทั้งหมด
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

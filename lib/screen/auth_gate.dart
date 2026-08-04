import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_dashboard_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/dashboard_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/login_screen.dart'; // ต้องมีไฟล์ login_screen.dart

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ายังไม่ได้ล็อกอิน (User เป็น null) ให้ไปที่หน้า Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ถ้าล็อกอินแล้ว (User ไม่เป็น null) ให้ตรวจสอบ Role จาก Firestore
        return RoleBasedRedirect(user: snapshot.data!);
      },
    );
  }
}

class RoleBasedRedirect extends StatelessWidget {
  final User user;
  const RoleBasedRedirect({super.key, required this.user});

  Future<DocumentSnapshot> _getUserRole() {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        // ขณะกำลังโหลดข้อมูล Role
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // หากเกิดข้อผิดพลาดในการดึงข้อมูล หรือไม่พบข้อมูลผู้ใช้ใน Firestore
        // เราจะถือว่าเป็นนักเรียนโดยค่าเริ่มต้น หรือแสดงหน้า Dashboard ของนักเรียน
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const DashboardScreen();
        }

        // ดึงข้อมูล role จาก document
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        // ตรวจสอบ role แล้วนำทางไปยังหน้าที่ถูกต้อง
        if (role == 'teacher') {
          return const AdvisorDashboardScreen();
        } else {
          // สำหรับ role 'student' หรือ role อื่นๆ ที่ไม่รู้จัก
          return const DashboardScreen();
        }
      },
    );
  }
}
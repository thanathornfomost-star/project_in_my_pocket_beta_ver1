import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/login_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ายังไม่ได้ล็อกอิน ให้ไปหน้า Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ถ้าล็อกอินแล้ว ให้ไปหน้า Dashboard
        return const DashboardScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock user data
  final Map<String, dynamic> userData = const {
    'name': 'สมชาย ใจดี',
    'username': 'somchai.jd',
    'email': 'somchai.j@kks.ac.th',
    'role': 'student', // 'student' or 'teacher'
    'school': 'โรงเรียนขุขันธ์',
    'level': 'มัธยมศึกษาปีที่ 5',
    'subject': 'วิทยาการคอมพิวเตอร์',
  };

  Future<void> _logout(BuildContext context) async {
    // In a real app, you'd clear tokens, etc.
    // For mockup, just navigate.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('ชื่อ-นามสกุล'),
            subtitle: Text(userData['name'] ?? 'ไม่มีข้อมูล'),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('ชื่อผู้ใช้'),
            subtitle: Text(userData['username'] ?? 'ไม่มีข้อมูล'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('อีเมล'),
            subtitle: Text(userData['email'] ?? 'ไม่มีข้อมูล'),
          ),
          if (userData['role'] == 'student')
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('โรงเรียน'),
              subtitle: Text(userData['school'] ?? 'ไม่มีข้อมูล'),
            ),
          if (userData['role'] == 'student')
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('ระดับชั้น'),
              subtitle: Text(userData['level'] ?? 'ไม่มีข้อมูล'),
            ),
          if (userData['role'] == 'teacher')
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('วิชาที่สอน'),
              subtitle: Text(userData['subject'] ?? 'ไม่มีข้อมูล'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

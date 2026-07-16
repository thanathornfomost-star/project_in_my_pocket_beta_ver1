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
    'subject': 'วิทยาการคอมพิวเตอร์', // For teacher role
    'avatarEmoji': '🧑‍💻',
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
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 32),
          // --- Profile Header ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    userData['avatarEmoji'] ?? '🧑‍💻',
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userData['name'] ?? 'ไม่มีข้อมูล',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'] ?? 'ไม่มีข้อมูล',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // --- Details Section ---
          _buildProfileDetailRow(
            icon: Icons.account_circle_outlined,
            title: 'ชื่อผู้ใช้',
            value: userData['username'] ?? 'ไม่มีข้อมูล',
          ),
          const SizedBox(height: 20),
          if (userData['role'] == 'student') ...[
            _buildProfileDetailRow(
              icon: Icons.school_outlined,
              title: 'โรงเรียน',
              value: userData['school'] ?? 'ไม่มีข้อมูล',
            ),
            const SizedBox(height: 20),
            _buildProfileDetailRow(
              icon: Icons.bar_chart_outlined,
              title: 'ระดับชั้น',
              value: userData['level'] ?? 'ไม่มีข้อมูล',
            ),
          ],
          const SizedBox(height: 32),

          // --- Logout Button ---
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper widget for displaying profile details
  Widget _buildProfileDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

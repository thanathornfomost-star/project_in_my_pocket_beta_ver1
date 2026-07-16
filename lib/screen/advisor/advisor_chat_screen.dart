import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_dashboard_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_project_chat_screen.dart';

class AdvisorChatScreen extends StatelessWidget {
  const AdvisorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ กรุณาล็อกอินใหม่")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Use a light background color
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Events')
            .where('memberUids', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีโครงงานในที่ปรึกษา\nเพื่อเริ่มการสนทนา',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final projectDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: projectDocs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final group = ProjectGroup.fromFirestore(projectDocs[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF007AFF),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ห้องแชทสำหรับโครงงาน ${group.name}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdvisorProjectChatScreen(projectGroup: group),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

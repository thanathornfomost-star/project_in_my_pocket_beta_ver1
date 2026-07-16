import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/project_chat_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("ไม่พบผู้ใช้ กรุณาล็อกอินใหม่"));
    }
    return StreamBuilder<QuerySnapshot>(
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
              'ยังไม่มีโครงงาน\nเพื่อเริ่มการสนทนา',
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
            final projectData =
                projectDocs[index].data() as Map<String, dynamic>;
            final projectId = projectDocs[index].id;
            final projectName = projectData['name_th'] ?? 'ไม่มีชื่อโครงงาน';
            final List<dynamic> members = projectData['members'] ?? [];
            final int memberCount = members.length;
            final bool hasTeacher = members.any((m) => m['role'] == 'teacher');

            final subtitleText =
                'สมาชิก $memberCount คน ${hasTeacher ? '(มีที่ปรึกษา)' : ''}';

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
                  projectName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(fontSize: 12, color: Colors.grey[600]),
                    children: [
                      TextSpan(text: 'สมาชิก $memberCount คน '),
                      if (hasTeacher)
                        const TextSpan(
                          text: '(มีที่ปรึกษา)',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentProjectChatScreen(
                        projectId: projectId,
                        projectName: projectName,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

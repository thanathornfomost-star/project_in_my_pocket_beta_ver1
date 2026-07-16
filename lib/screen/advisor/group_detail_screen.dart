import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_dashboard_screen.dart';

// Mockup data for members
class ProjectMember {
  final String name;
  final String emoji;
  ProjectMember({required this.name, required this.emoji});
}

class GroupDetailScreen extends StatefulWidget {
  final ProjectGroup projectGroup;

  const GroupDetailScreen({super.key, required this.projectGroup});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  // Re-using the status color logic. It might be better to move this to a utility file later.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'เสนอหัวข้อ':
        return Colors.blue.shade700;
      case 'กำลังดำเนินการ':
        return Colors.orange.shade700;
      case 'รอสอบ':
        return Colors.purple.shade700;
      case 'เสร็จสิ้น':
        return Colors.green.shade700;
      case 'แก้ไข':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'รายละเอียดกลุ่มโครงงาน',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(),
            const SizedBox(height: 24),
            const Text(
              'สมาชิกในกลุ่ม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildMembersList(),
            const SizedBox(height: 24),
            _buildTaskList(widget.projectGroup.id),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectGroup.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildTaskProgress(widget.projectGroup.id),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.projectGroup.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('ไม่พบข้อมูลโครงงาน'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> membersData = data['members'] ?? [];
        if (membersData.isEmpty) {
          return const Text("ไม่พบข้อมูลสมาชิก");
        }

        // Sort the list to put the advisor (current user) at the top
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        membersData.sort((a, b) {
          final aMap = a as Map<String, dynamic>;
          final bMap = b as Map<String, dynamic>;
          if (aMap['uid'] == currentUserUid) {
            return -1; // a (advisor) comes first
          }
          if (bMap['uid'] == currentUserUid) {
            return 1; // b (advisor) comes first
          }
          return 0; // Keep original order for others
        });

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: membersData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final memberMap = membersData[index] as Map<String, dynamic>;
              return ListTile(
                leading: Text(
                  memberMap['emoji'] ?? '🧑‍💻',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(memberMap['name'] ?? 'ไม่มีชื่อ'),
                trailing:
                    memberMap['uid'] == FirebaseAuth.instance.currentUser?.uid
                    ? const Text(
                        'ที่ปรึกษา',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    : null,
              );
            },
          ), // 🟢 เปลี่ยนจาก ); เป็น ), เพื่อให้ ListView อยู่ใน Card
        ); // 🟢 ปิด Card ด้วย );
      }, // 🟢 ปิด builder ของ StreamBuilder
    ); // 🟢 ปิด return StreamBuilder
  }

  Widget _buildTaskProgress(String projectId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Events')
          .doc(projectId)
          .collection('tasks')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 8); // Return empty space while loading
        }
        final tasks = snapshot.data?.docs ?? [];
        final totalTasks = tasks.length;
        final doneTasks = tasks
            .where(
              (doc) => (doc.data() as Map<String, dynamic>)['isDone'] == true,
            )
            .length;
        final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ความคืบหน้าของงาน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList(String projectId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Events')
          .doc(projectId)
          .collection('tasks')
          .where('isDone', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ไม่มีงานที่ต้องทำ'));
        }

        final tasks = snapshot.data!.docs;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'งานที่ต้องทำ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final taskData = tasks[index].data() as Map<String, dynamic>;
                  final dueDate = (taskData['dueDate'] as Timestamp?)?.toDate();

                  return ListTile(
                    leading: const Icon(Icons.check_box_outline_blank),
                    title: Text(taskData['title'] ?? 'ไม่มีชื่องาน'),
                    subtitle: dueDate != null
                        ? Text(
                            'กำหนดส่ง: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

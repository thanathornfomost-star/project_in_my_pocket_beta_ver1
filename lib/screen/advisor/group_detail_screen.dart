import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// Helper Function สำหรับเปิดไฟล์แนบ
Future<void> _openAttachmentUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $url");
  }
}

// Widget แสดงรายการไฟล์แนบสำหรับหน้า Advisor
Widget _buildAdvisorAttachmentsList(List<dynamic> attachments) {
  if (attachments.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 6),
      const Row(
        children: [
          Icon(Icons.attach_file, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            'ไฟล์แนบจากนักเรียน:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ...attachments.map((attachment) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(
          attachment as Map,
        );
        final String name = item['name'] ?? 'ไฟล์แนบ';
        final String url = item['url'] ?? '';

        return InkWell(
          onTap: () => _openAttachmentUrl(url),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.download, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      }).toList(),
    ],
  );
}

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
            const Text(
              'ติดตามงานของนักเรียน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
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

        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        membersData.sort((a, b) {
          final aMap = a as Map<String, dynamic>;
          final bMap = b as Map<String, dynamic>;
          if (aMap['uid'] == currentUserUid) {
            return -1;
          }
          if (bMap['uid'] == currentUserUid) {
            return 1;
          }
          return 0;
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
          ),
        );
      },
    );
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
          return const SizedBox(height: 8);
        }
        final tasks = snapshot.data?.docs ?? [];
        final totalTasks = tasks.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          return d['isChapter'] != true; // คำนวณความคืบหน้าเฉพาะงานย่อย
        }).length;

        final doneTasks = tasks.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          return d['isChapter'] != true && d['isDone'] == true;
        }).length;

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
                        backgroundColor: const Color(0xFFE6F2FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF007AFF),
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
                    color: Color(0xFF007AFF),
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
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ไม่มีรายการงาน'));
        }

        final allTasks = snapshot.data!.docs;

        // จัดเรียงตามลำดับ order
        allTasks.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aOrder = aData['order'] as int?;
          final bOrder = bData['order'] as int?;

          if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);
          if (aOrder != null) return -1;
          if (bOrder != null) return 1;
          return 0;
        });

        // แยก Chapter และ Sub-tasks
        final Map<DocumentSnapshot, List<DocumentSnapshot>> groupedTasks = {};
        DocumentSnapshot? currentChapter;
        final List<DocumentSnapshot> standaloneTasks = [];

        for (final task in allTasks) {
          final taskData = task.data() as Map<String, dynamic>;
          if (taskData['isChapter'] == true) {
            currentChapter = task;
            groupedTasks[currentChapter] = [];
          } else if (currentChapter != null &&
              (taskData['isTemplate'] == true ||
                  taskData['parentChapterId'] == currentChapter.id)) {
            groupedTasks[currentChapter]?.add(task);
          } else {
            standaloneTasks.add(task);
          }
        }

        return Column(
          children: [
            // แสดง Dropdown แบบ ExpansionTile สำหรับแต่ละบท
            ...groupedTasks.entries.map((entry) {
              final chapterDoc = entry.key;
              final chapterData = chapterDoc.data() as Map<String, dynamic>;
              final subTasks = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  title: Text(
                    chapterData['title'] ?? 'หมวดหมู่/บท',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  children: subTasks.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'ไม่มีงานย่อยในหัวข้อนี้',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ), // <-- ย้ายมาไว้ตรงนี้
                            ),
                          ),
                        ]
                      : subTasks.map((subTaskDoc) {
                          final taskData =
                              subTaskDoc.data() as Map<String, dynamic>;
                          final bool isDone = taskData['isDone'] ?? false;
                          final dueDate = (taskData['dueDate'] as Timestamp?)
                              ?.toDate();
                          final assignedTo = taskData['assignedTo'] != null
                              ? taskData['assignedTo']['name']
                              : null;
                          final List<dynamic> attachments =
                              taskData['attachments'] ?? [];

                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  isDone
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isDone ? Colors.green : Colors.grey,
                                ),
                                title: Text(
                                  taskData['title'] ?? 'ไม่มีชื่องาน',
                                  style: TextStyle(
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isDone
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (dueDate != null)
                                      Text(
                                        'กำหนดส่ง: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (assignedTo != null)
                                      Text(
                                        'ผู้รับผิดชอบ: $assignedTo',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    _buildAdvisorAttachmentsList(attachments),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                ),
              );
            }),

            // งานที่สร้างเพิ่มเติมทั่วไป (ถ้ามี)
            if (standaloneTasks.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'งานเพิ่มเติมอื่นๆ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              ...standaloneTasks.map((taskDoc) {
                final taskData = taskDoc.data() as Map<String, dynamic>;
                final bool isDone = taskData['isDone'] ?? false;
                final dueDate = (taskData['dueDate'] as Timestamp?)?.toDate();
                final List<dynamic> attachments = taskData['attachments'] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isDone ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isDone ? Colors.green : Colors.grey,
                    ),
                    title: Text(taskData['title'] ?? 'ไม่มีชื่องาน'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dueDate != null)
                          Text(
                            'กำหนดส่ง: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        _buildAdvisorAttachmentsList(attachments),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}

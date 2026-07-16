import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// --- Data Models (Mockup) ---

class Member {
  final String id;
  final String name;
  final String emoji;

  const Member({required this.id, required this.name, required this.emoji});

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['uid'] ?? '',
      name: map['name'] ?? 'Unknown',
      emoji: map['emoji'] ?? '🧑‍💻',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': id, 'name': name, 'emoji': emoji};
  }
}

// --- Main Screen Widget ---

class TaskBoardScreen extends StatefulWidget {
  final String projectId;
  const TaskBoardScreen({super.key, required this.projectId});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  void _showAddTaskDialog() async {
    List<Member> teamMembers = [];
    try {
      final projectDoc = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.projectId)
          .get();
      if (projectDoc.exists) {
        final membersData =
            (projectDoc.data()?['members'] as List<dynamic>?) ?? [];
        teamMembers = membersData.map((m) => Member.fromMap(m)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถโหลดรายชื่อสมาชิกได้'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    Member? selectedMember;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "สร้างงานใหม่",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Task Title
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'ชื่องาน',
                        hintText: 'เช่น "ออกแบบ Logo โครงงาน"',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาใส่ชื่องาน';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deadline
                    const Text(
                      "กำหนดส่ง",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Assignee
                    const Text(
                      "มอบหมายให้",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Member>(
                      value: selectedMember,
                      hint: const Text('เลือกสมาชิกในทีม'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      items: teamMembers.map((member) {
                        return DropdownMenuItem<Member>(
                          value: member,
                          child: Row(
                            children: [
                              Text(
                                member.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(member.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (member) {
                        setModalState(() {
                          selectedMember = member;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("ยกเลิก"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final newTaskData = {
                                  'title': titleController.text.trim(),
                                  'dueDate': Timestamp.fromDate(selectedDate!),
                                  'isDone': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'assignedTo': selectedMember?.toMap(),
                                };

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('Events')
                                      .doc(widget.projectId)
                                      .collection('tasks')
                                      .add(newTaskData);

                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('เกิดข้อผิดพลาด: $e'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "สร้างงาน",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'งานทั้งหมด',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Events')
            .doc(widget.projectId)
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีงานในโครงงานนี้\nกดปุ่ม + เพื่อสร้างงานแรก',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskDoc = tasks[index];
              return _TaskListItem(
                taskDoc: taskDoc,
                onChanged: (isDone) =>
                    taskDoc.reference.update({'isDone': isDone ?? false}),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- Task List Item Widget ---

class _TaskListItem extends StatelessWidget {
  final DocumentSnapshot taskDoc;
  final ValueChanged<bool?> onChanged;

  const _TaskListItem({required this.taskDoc, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final taskData = taskDoc.data() as Map<String, dynamic>;
    final bool isDone = taskData['isDone'] ?? false;
    final DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
    final bool isOverdue = !isDone && dueDate.isBefore(DateTime.now());
    final Map<String, dynamic>? assignedToData =
        taskData['assignedTo'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: onChanged,
              activeColor: const Color(0xFF4F46E5),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskData['title'] ?? 'ไม่มีชื่องาน',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDone ? Colors.grey : Colors.black87,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: isOverdue ? Colors.red.shade700 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (assignedToData != null)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4F46E5).withOpacity(0.2),
                child: Text(
                  assignedToData['emoji'] ?? '?',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            else
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black12,
                child: Icon(Icons.person_outline, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// --- Data Models (Mockup) ---

class Member {
  final String id;
  final String name;
  final String emoji;
  final String role; // 'student' or 'teacher'

  const Member({
    required this.id,
    required this.name,
    required this.emoji,
    required this.role,
  });
}

class Task {
  final String id;
  String title;
  DateTime dueDate;
  Member? assignedTo;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    this.assignedTo,
    this.isDone = false,
  });
}

// --- Main Screen Widget ---

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  // Mock Data
  final List<Member> _teamMembers = [
    const Member(id: '1', name: 'อลิซ', emoji: '👩‍🎓', role: 'student'),
    const Member(id: '2', name: 'บ็อบ', emoji: '🧑‍💻', role: 'student'),
    const Member(id: '3', name: 'ชาลี', emoji: '👨‍🎨', role: 'student'),
    const Member(id: '4', name: 'อ.เดวิด', emoji: '🧑‍🏫', role: 'teacher'),
  ];

  final List<Task> _tasks = [
    Task(
      id: 't1',
      title: 'สรุปบทที่ 3',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      assignedTo: const Member(id: '1', name: 'อลิซ', emoji: '👩‍🎓', role: 'student'),
      isDone: false,
    ),
    Task(
      id: 't2',
      title: 'ร่วมวัตถุประสงค์ (วิชาเอก)',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      assignedTo: const Member(id: '2', name: 'บ็อบ', emoji: '🧑‍💻', role: 'student'),
      isDone: false,
    ),
    Task(
      id: 't3',
      title: 'สรุปผลทดลองที่ 1',
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      assignedTo: const Member(id: '1', name: 'อลิซ', emoji: '👩‍🎓', role: 'student'),
      isDone: true,
    ),
    Task(
      id: 't4',
      title: 'ออกแบบ UI หน้าแรก',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isDone: false,
    ),
  ];

  void _showAddTaskDialog() {
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
                      items: _teamMembers.map((member) {
                        return DropdownMenuItem<Member>(
                          value: member,
                          child: Row(
                            children: [
                              Text(member.emoji,
                                  style: const TextStyle(fontSize: 18)),
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
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final newTask = Task(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: titleController.text,
                                  dueDate: selectedDate!,
                                  assignedTo: selectedMember,
                                );
                                setState(() {
                                  _tasks.insert(0, newTask);
                                });
                                Navigator.pop(context);
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _TaskListItem(
            task: task,
            onChanged: (isDone) {
              setState(() {
                task.isDone = isDone ?? false;
              });
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
  final Task task;
  final ValueChanged<bool?> onChanged;

  const _TaskListItem({required this.task, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isDone && task.dueDate.isBefore(DateTime.now());
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
              value: task.isDone,
              onChanged: onChanged,
              activeColor: const Color(0xFF4F46E5),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isDone ? Colors.grey : Colors.black87,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
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
                        "${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
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
            if (task.assignedTo != null)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4F46E5).withOpacity(0.2),
                child: Text(
                  task.assignedTo!.emoji,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
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

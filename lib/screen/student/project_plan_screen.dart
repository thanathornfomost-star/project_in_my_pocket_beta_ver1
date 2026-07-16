import 'package:flutter/material.dart';

class Milestone {
  String id;
  String title;
  DateTime dueDate;
  bool isCompleted;

  Milestone({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class ProjectPlanScreen extends StatefulWidget {
  // final String projectId; // We don't need this for the mockup

  const ProjectPlanScreen({super.key});

  @override
  State<ProjectPlanScreen> createState() => _ProjectPlanScreenState();
}

class _ProjectPlanScreenState extends State<ProjectPlanScreen> {
  final List<Milestone> _milestones = [
    Milestone(
      id: '1',
      title: 'บทที่ 1: บทนำ',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: true,
    ),
    Milestone(
      id: '2',
      title: 'บทที่ 2: เอกสารที่เกี่ยวข้อง',
      dueDate: DateTime.now().add(const Duration(days: 21)),
    ),
    Milestone(
      id: '3',
      title: 'บทที่ 3: วิธีการดำเนินงาน',
      dueDate: DateTime.now().add(const Duration(days: 45)),
    ),
  ];

  void _addMilestone() {
    final titleController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เพิ่มแผนงานใหม่ (Milestone)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'ชื่อแผนงาน'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: const Text('เลือกวันครบกำหนด'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  setState(() {
                    _milestones.add(
                      Milestone(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        dueDate: selectedDate!,
                      ),
                    );
                    _milestones.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('สร้าง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แผนโครงงาน (Milestones)'),
        centerTitle: true,
      ),
      body: _milestones.isEmpty
          ? const Center(
              child: Text(
                'ยังไม่มีแผนงาน\nกดปุ่ม + เพื่อเริ่มสร้างแผนงานแรกของคุณ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _milestones.length,
              itemBuilder: (context, index) {
                final milestone = _milestones[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: milestone.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          milestone.isCompleted = value ?? false;
                        });
                      },
                    ),
                    title: Text(
                      milestone.title,
                      style: TextStyle(
                        decoration: milestone.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      'ครบกำหนด: ${milestone.dueDate.day}/${milestone.dueDate.month}/${milestone.dueDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _milestones.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMilestone,
        child: const Icon(Icons.add),
      ),
    );
  }
}

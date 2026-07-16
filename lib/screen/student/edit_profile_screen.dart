import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Mock data for editing
  final String _userRole = "student"; // This cannot be changed

  final _nameController = TextEditingController(text: "สมชาย ใจดี");
  final _schoolController = TextEditingController(text: "โรงเรียนขุขันธ์");
  final _levelController = TextEditingController(text: "มัธยมศึกษาปีที่ 5");
  final _subjectController = TextEditingController(text: "วิทยาการคอมพิวเตอร์");

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _levelController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลส่วนตัว'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uneditable Role
            const Text(
              "บทบาท",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _userRole == 'student' ? 'นักเรียน' : 'อาจารย์',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณไม่สามารถแก้ไขบทบาทได้',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Editable fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ-นามสกุล',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Conditional fields based on role
            if (_userRole == 'student') ...[
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'โรงเรียน',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(
                  labelText: 'ระดับชั้น',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'วิชาที่สอน',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'โรงเรียน',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('บันทึกการเปลี่ยนแปลง'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('ยกเลิก'),
            ),
          ],
        ),
      ),
    );
  }
}

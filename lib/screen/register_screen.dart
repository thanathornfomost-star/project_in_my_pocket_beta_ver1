import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _subjectController = TextEditingController();
  final _teacherSchoolController = TextEditingController();

  // State Variables
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  int _selectedRoleIndex = 0; // 0 = นักเรียน, 1 = อาจารย์
  bool _isLoading = false;
  bool _isAcceptedTerms = false;

  // Dropdown Values (สำหรับนักเรียน)
  String? _selectedSchool;
  String? _selectedLevel;

  // ข้อมูลจำลองสำหรับ Dropdown
  final List<String> _schools = [
    'โรงเรียนขุขันธ์',
    'โรงเรียนมัธยมสาธิต',
    'โรงเรียนนานาชาติรวมมิตร',
  ];
  final List<String> _levels = [
    'มัธยมศึกษาปีที่ 1',
    'มัธยมศึกษาปีที่ 2',
    'มัธยมศึกษาปีที่ 3',
    'มัธยมศึกษาปีที่ 4',
    'มัธยมศึกษาปีที่ 5',
    'มัธยมศึกษาปีที่ 6',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _subjectController.dispose();
    _teacherSchoolController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_isAcceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณายอมรับเงื่อนไขการใช้งาน')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Create user with email and password
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 2. Save additional user data to Firestore
        if (userCredential.user != null) {
          final userDoc = FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid);

          final userData = {
            'uid': userCredential.user!.uid,
            'name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRoleIndex == 0 ? 'student' : 'teacher',
            'createdAt': FieldValue.serverTimestamp(),
            'avatarEmoji': _selectedRoleIndex == 0
                ? '🧑‍🎓'
                : '🧑‍🏫', // Default emoji
            // Add role-specific data
            if (_selectedRoleIndex == 0) ...{
              'school': _selectedSchool,
              'level': _selectedLevel,
            } else ...{
              'subject': _subjectController.text.trim(),
              'school': _teacherSchoolController.text.trim(),
            },
          };

          await userDoc.set(userData);
        }
        // Navigation is handled by AuthGate
      } on FirebaseAuthException catch (e) {
        String message = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
        if (e.code == 'weak-password') {
          message = 'รหัสผ่านไม่ปลอดภัย';
        } else if (e.code == 'email-already-in-use') {
          message = 'อีเมลนี้ถูกใช้งานแล้ว';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ชื่อ-นามสกุล
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "โปรดกรอกข้อมูลให้ครบ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. อีเมล
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "โปรดกรอกข้อมูลให้ครบ";
                    }
                    // แถม: เช็กรูปแบบอีเมลเบื้องต้นให้ด้วยครับ
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return "รูปแบบอีเมลไม่ถูกต้อง";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. ชื่อผู้ใช้
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "โปรดกรอกข้อมูลให้ครบ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. รหัสผ่าน
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscurePassword = !_isObscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "โปรดกรอกข้อมูลให้ครบ";
                    }
                    if (value.length < 6) {
                      return "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. ยืนยันรหัสผ่าน (เพิ่มระบบตรวจสอบที่นี่ครับ ✨)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_clock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirmPassword =
                              !_isObscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "โปรดกรอกข้อมูลให้ครบ";
                    }
                    // เช็กว่าข้อความตรงกับช่องรหัสผ่านหลักไหม
                    if (value != _passwordController.text) {
                      return "รหัสผ่านไม่ตรงกัน";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 6. เลือกบทบาท (Segmented Control)
                const Text(
                  'เลือกบทบาท',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ToggleButtons(
                    isSelected: [
                      _selectedRoleIndex == 0,
                      _selectedRoleIndex == 1,
                    ],
                    onPressed: (int index) {
                      setState(() {
                        _selectedRoleIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    constraints: BoxConstraints(
                      minWidth: (MediaQuery.of(context).size.width - 60) / 2,
                      minHeight: 45,
                    ),
                    children: const [Text('นักเรียน'), Text('อาจารย์')],
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Dynamic Fields ตามบทบาท
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedRoleIndex == 0
                      ? _buildStudentFields()
                      : _buildTeacherFields(),
                ),
                const SizedBox(height: 16),

                // 8. Checkbox ยอมรับเงื่อนไข
                Row(
                  children: [
                    Checkbox(
                      value: _isAcceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAcceptedTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('ยอมรับ '),
                          GestureDetector(
                            onTap: () {
                              debugPrint('ไปหน้าอ่านเงื่อนไข');
                            },
                            child: const Text(
                              'เงื่อนไขการใช้งาน',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 9. ปุ่มสมัครสมาชิก
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 24),

                // ด้านล่างสุด: ลิงก์กลับหน้า Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('มีบัญชีแล้ว? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 7a. ฟิลด์สำหรับ นักเรียน (เพิ่ม validator ให้ Dropdown)
  Widget _buildStudentFields() {
    return Column(
      key: const ValueKey('StudentFields'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedSchool,
          decoration: const InputDecoration(
            labelText: 'โรงเรียน',
            border: OutlineInputBorder(),
          ),
          items: _schools.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedSchool = newValue;
            });
          },
          validator: (value) => value == null ? "โปรดเลือกโรงเรียน" : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedLevel,
          decoration: const InputDecoration(
            labelText: 'ระดับชั้น',
            border: OutlineInputBorder(),
          ),
          items: _levels.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedLevel = newValue;
            });
          },
          validator: (value) => value == null ? "โปรดเลือกระดับชั้น" : null,
        ),
      ],
    );
  }

  // 7b. ฟิลด์สำหรับ อาจารย์ (เพิ่ม validator ให้ TextField)
  Widget _buildTeacherFields() {
    return Column(
      key: const ValueKey('TeacherFields'),
      children: [
        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: 'วิชาที่สอน',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "โปรดกรอกวิชาที่สอน";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _teacherSchoolController,
          decoration: const InputDecoration(
            labelText: 'โรงเรียน',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "โปรดกรอกชื่อโรงเรียน";
            }
            return null;
          },
        ),
      ],
    );
  }
}

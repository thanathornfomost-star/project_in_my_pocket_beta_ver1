import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  String _selectedEmoji = '🧑‍💻';

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(String uid) async {
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณากรอกชื่อ-สกุล'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'avatarEmoji': _selectedEmoji,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _translateRole(String role) {
    switch (role) {
      case 'student':
        return 'นักเรียน/นักศึกษา';
      case 'teacher':
        return 'อาจารย์';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้, กรุณาเข้าสู่ระบบอีกครั้ง")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          if (!_isEditing) {
            _nameController.text = userData['name'] ?? '';
            _selectedEmoji = userData['avatarEmoji'] ?? '🧑‍💻';
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                _buildProfileHeader(userData),
                const SizedBox(height: 24),
                _buildProfileCard(userData),
                const SizedBox(height: 16),
                _buildActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final String name = userData['name'] ?? 'ไม่มีชื่อ';
    final String email = userData['email'] ?? _user!.email ?? 'ไม่มีอีเมล';
    final String emoji = userData['avatarEmoji'] ?? '🧑‍💻';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _isEditing ? _selectedEmoji : emoji,
              style: const TextStyle(fontSize: 50),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? _nameController.text : name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ข้อมูลส่วนตัว',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF007AFF),
                    ),
                    tooltip: 'แก้ไขข้อมูล',
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const Divider(height: 24),
            _isEditing ? _buildEditForm(userData) : _buildDisplayInfo(userData),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayInfo(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildInfoRow(
          Icons.person_outline,
          'ชื่อ-สกุล',
          userData['name'] ?? '-',
        ),
        _buildInfoRow(Icons.alternate_email, 'อีเมล', userData['email'] ?? '-'),
        _buildInfoRow(
          Icons.school_outlined,
          'สถานศึกษา',
          userData['schoolName'] ?? 'ยังไม่ระบุ',
        ),
        _buildInfoRow(
          Icons.badge_outlined,
          'บทบาท',
          _translateRole(userData['role'] ?? '-'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'ชื่อ-สกุล',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.school_outlined,
          'สถานศึกษา (ไม่สามารถแก้ไขได้)',
          userData['schoolName'] ?? 'ยังไม่ระบุ',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.alternate_email,
          'อีเมล (ไม่สามารถแก้ไขได้)',
          userData['email'] ?? '-',
        ),
        _buildInfoRow(
          Icons.badge_outlined,
          'บทบาท (ไม่สามารถแก้ไขได้)',
          _translateRole(userData['role'] ?? '-'),
        ),
        const SizedBox(height: 20),
        _buildEmojiPicker(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = userData['name'] ?? '';
                  _selectedEmoji = userData['avatarEmoji'] ?? '🧑‍💻';
                });
              },
              child: const Text('ยกเลิก'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _saveChanges(_user!.uid),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 20),
              label: const Text('บันทึก'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final emojis = [
      '🧑‍💻',
      '🧑‍🔬',
      '🎨',
      '💡',
      '🚀',
      '🧠',
      '✍️',
      '👩‍🎓',
      '👨‍🏫',
      '🔬',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เลือกไอคอนประจำตัว',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: emojis.map((emoji) {
              bool isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007AFF).withOpacity(0.2)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF007AFF), width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ยืนยันการออกจากระบบ'),
            content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'ยืนยัน',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await FirebaseAuth.instance.signOut();
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('ออกจากระบบ'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Color.fromARGB(255, 255, 205, 210)),
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  void _showJoinProjectDialog(Map<String, dynamic> userData) {
    final codeController = TextEditingController();
    bool isLoadingInDialog = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'เข้าร่วมโครงงาน',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'กรอกโค้ดเชิญที่ได้รับเพื่อเข้าร่วมโครงงาน',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: codeController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'PJM-XXXXXX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingInDialog
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: isLoadingInDialog
                      ? null
                      : () async {
                          final inviteCode = codeController.text.trim();
                          if (inviteCode.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณากรอกโค้ดเชิญ'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoadingInDialog = true);

                          final firestore = FirebaseFirestore.instance;
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            setDialogState(() => isLoadingInDialog = false);
                            return;
                          }

                          try {
                            final projectQuery = await firestore
                                .collection('Events')
                                .where('inviteCode', isEqualTo: inviteCode)
                                .limit(1)
                                .get();

                            if (projectQuery.docs.isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ไม่พบโครงงานสำหรับโค้ดนี้'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              final projectDoc = projectQuery.docs.first;
                              final projectData = projectDoc.data();
                              final projectName =
                                  projectData['name_th'] ?? 'โครงงานไม่มีชื่อ';
                              final List<dynamic> memberUids =
                                  projectData['memberUids'] ?? [];

                              if (memberUids.contains(user.uid)) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'คุณเป็นสมาชิกของโครงงานนี้อยู่แล้ว',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              } else {
                                // Show confirmation dialog
                                final confirmJoin = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'ยืนยันการเข้าร่วมโครงงาน',
                                    ),
                                    content: Text(
                                      'คุณต้องการเข้าร่วมโครงงาน "$projectName" ใช่หรือไม่?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('ยืนยัน'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmJoin == true) {
                                  final newMemberData = {
                                    'uid': user.uid,
                                    'name': userData['name'],
                                    'emoji': userData['avatarEmoji'],
                                    'role': userData['role'],
                                  };

                                  await projectDoc.reference.update({
                                    'memberUids': FieldValue.arrayUnion([
                                      user.uid,
                                    ]),
                                    'members': FieldValue.arrayUnion([
                                      newMemberData,
                                    ]),
                                  });

                                  if (mounted) {
                                    Navigator.pop(
                                      context,
                                    ); // Close the first dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('เข้าร่วมโครงงานสำเร็จ!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  // User cancelled the confirmation, just close the confirmation dialog
                                  // and keep the invite code dialog open.
                                }
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('เกิดข้อผิดพลาด: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isLoadingInDialog = false);
                            }
                          }
                        },
                  child: isLoadingInDialog
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('เข้าร่วม'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

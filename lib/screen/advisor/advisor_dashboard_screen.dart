import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_chat_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_project_chat_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/advisor_profile_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/advisor/group_detail_screen.dart';

// Model สำหรับข้อมูลกลุ่มโครงงาน
class ProjectGroup {
  final String id;
  final String name;
  final String status;

  ProjectGroup({required this.id, required this.name, required this.status});

  // Factory constructor สำหรับสร้าง ProjectGroup จาก Firestore document
  factory ProjectGroup.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProjectGroup(
      id: doc.id,
      name: data['name_th'] ?? 'ไม่มีชื่อโครงงาน',
      status:
          data['status'] ?? 'ไม่ระบุ', // สมมติว่ามี field 'status' ใน document
    );
  }
}

class AdvisorDashboardScreen extends StatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  State<AdvisorDashboardScreen> createState() => _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState extends State<AdvisorDashboardScreen> {
  int _activeNavIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(_buildDashboardContent()); // Home Page
    _pages.add(const AdvisorChatScreen()); // Chat Page
    _pages.add(const AdvisorProfileScreen()); // Profile Page
  }

  // ฟังก์ชันสำหรับ map สถานะเป็นสี
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

  void _navigateToProjectDetails(ProjectGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(projectGroup: group),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์นี้กำลังจะมาในเร็วๆ นี้ (Coming Soon)'),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showJoinProjectDialog() {
    final codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
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
                    'กรอกโค้ดเชิญของโครงงานเพื่อเข้าร่วมเป็นที่ปรึกษา',
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
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);
                          await _joinProjectWithCode(
                            codeController.text.trim(),
                          );
                          if (mounted) {
                            setDialogState(() => isLoading = false);
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // กรณีที่ไม่ควรเกิดขึ้นหากผ่าน AuthGate มาแล้ว
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ กรุณาล็อกอินใหม่")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String userAvatar = userData['avatarEmoji'] ?? '🧑‍🏫';

        return Scaffold(
          backgroundColor: const Color(
            0xFFF8FAFC,
          ), // สีพื้นหลังเหมือนหน้าของนักเรียน
          appBar: AppBar(
            title: const Text('หน้าหลัก (อาจารย์)'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.black12,
            titleSpacing: 16,
            titleTextStyle: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  // TODO: Implement notification screen
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _activeNavIndex = 2;
                  });
                },
                child: Container(
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      userAvatar,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: _pages[_activeNavIndex],
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, "Home"),
          _buildNavItem(1, Icons.chat_bubble_rounded, "Chat"),
          _buildNavItem(2, Icons.person_rounded, "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("ไม่พบผู้ใช้"));

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

        final projectDocs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(projectDocs.length),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "โครงงานในที่ปรึกษา",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              _buildProjectList(projectDocs),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  "เมนูลัด",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              _buildQuickActions(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(int projectCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB3D7FF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.supervisor_account_rounded,
            color: Color(0xFF007AFF),
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            "มีโครงงานในที่ปรึกษา $projectCount กลุ่ม",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(List<QueryDocumentSnapshot> projectDocs) {
    if (projectDocs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Text(
            "ยังไม่มีโครงงานในที่ปรึกษา",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: projectDocs.length,
      itemBuilder: (context, index) {
        final group = ProjectGroup.fromFirestore(projectDocs[index]);
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () => _navigateToProjectDetails(group),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_shared_outlined,
                    color: Color(0xFF007AFF),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildQuickActionCard("📅", "ปฏิทินนัดหมาย", onTap: _showComingSoon),
          _buildQuickActionCard("✅", "อนุมัติเอกสาร", onTap: _showComingSoon),
          _buildQuickActionCard(
            "🧑‍🏫",
            "เข้าร่วมด้วยโค้ด",
            onTap: () {
              _showJoinProjectDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _activeNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNavIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF007AFF)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              )
            else
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinProjectWithCode(String code) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกโค้ดเชิญ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final userData = userDoc.data();

    if (user == null || userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบข้อมูลผู้ใช้'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('Events')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบโครงงานสำหรับโค้ดนี้'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final projectDoc = query.docs.first;
    final newMemberData = {
      'uid': user.uid,
      'name': userData['name'],
      'emoji': userData['avatarEmoji'],
    };

    await projectDoc.reference.update({
      'memberUids': FieldValue.arrayUnion([user.uid]),
      'members': FieldValue.arrayUnion([newMemberData]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เข้าร่วมโครงงานสำเร็จ!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

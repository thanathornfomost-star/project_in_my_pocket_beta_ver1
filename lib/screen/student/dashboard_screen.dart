import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/learn_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/profile_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/chat_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/task_board_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/util/project_templates.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeNavIndex = 0;
  String? _activeProjectId;
  // ลำดับเมนูด้านล่างสุด (0: Home, 1: Learn, 2: Tasks, 3: Chat, 4: Profile)

  // ข้อมูลโครงงานเริ่มต้นสำหรับการนำเสนอ
  // Map<String, dynamic> _activeProject = {
  //   'id': 'proj1',
  //   'name_th': "โครงงานพัฒนาโมบายแอปพลิเคชันเพื่อการศึกษา",
  //   'name_en': "Mobile App for Education",
  //   'type': 'NSC',
  //   'inviteCode': 'PJM-AB12CD',
  // };

  // รายการงานสัปดาห์นี้ (unused field removed)

  // Mock user data
  // final Map<String, dynamic> _userData = {'avatarEmoji': '🧑‍💻'}; // Replaced with Firebase data

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'PJM-${String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))))}';
  }

  // Widget สำหรับแสดงผลตามเมนูที่เลือก
  Widget _buildPageForIndex(
    int index,
    bool hasProject,
    Map<String, dynamic>? activeProject,
    Map<String, dynamic> userData,
  ) {
    switch (index) {
      case 0:
        return hasProject
            ? _buildActiveState(activeProject!)
            : _buildEmptyState(userData);
      case 1:
        return const LearnScreen(); // แสดงหน้าคลังความรู้
      case 2:
        return hasProject
            ? TaskBoardScreen(projectId: activeProject!['id'])
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "สร้างหรือเข้าร่วมโครงงานก่อน จึงจะสามารถดูบอร์ดงานได้",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
      case 3:
        return hasProject
            ? const ChatScreen()
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "สร้างหรือเข้าร่วมโครงงานเพื่อเริ่มแชทกับทีม",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
      case 4:
        return const ProfileScreen();
      default:
        return hasProject
            ? _buildActiveState(activeProject!)
            : _buildEmptyState(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้, กรุณาเข้าสู่ระบบใหม่อีกครั้ง")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Events')
              .where('memberUids', arrayContains: user.uid)
              .snapshots(),
          builder: (context, projectSnapshot) {
            if (projectSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (projectSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('เกิดข้อผิดพลาด: ${projectSnapshot.error}'),
                ),
              );
            }

            final userProjects = projectSnapshot.data?.docs ?? [];
            final bool hasProject = userProjects.isNotEmpty;
            Map<String, dynamic>? activeProject;

            if (hasProject) {
              // If no active project is selected, or if the selected one is gone, default to the first one.
              if (_activeProjectId == null ||
                  !userProjects.any((doc) => doc.id == _activeProjectId)) {
                _activeProjectId = userProjects.first.id;
              }

              // Find the active project from the list.
              final activeProjectDoc = userProjects.firstWhere(
                (doc) => doc.id == _activeProjectId,
              );

              activeProject = activeProjectDoc.data() as Map<String, dynamic>;
              activeProject['id'] = activeProjectDoc.id;
            } else {
              _activeProjectId = null; // No projects, so no active ID.
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(
                context,
                hasProject,
                activeProject?['name_th'] ?? 'ยังไม่มีโครงงาน',
                userData['avatarEmoji'] ?? '🧑‍💻',
                userProjects,
                userData,
              ),
              body: _buildPageForIndex(
                _activeNavIndex,
                hasProject,
                activeProject,
                userData,
              ),
              bottomNavigationBar: _buildBottomNavBar(),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveState(Map<String, dynamic> activeProject) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD: Project Health (margin 16px, padding 16px, border-radius 16px)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Events')
                  .doc(activeProject['id'])
                  .collection('tasks')
                  .snapshots(),
              builder: (context, taskSnapshot) {
                final tasks = taskSnapshot.data?.docs ?? [];
                final totalTasks = tasks.length;
                final doneTasks = tasks
                    .where(
                      (doc) =>
                          (doc.data() as Map<String, dynamic>)['isDone'] ==
                          true,
                    )
                    .length;
                final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

                return Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ความคืบหน้าโครงงาน",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 8,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFE0E7FF),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4F46E5),
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
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // SECTION: งานสัปดาห์นี้
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "งานที่ต้องทำ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _activeNavIndex = 2;
                    });
                  },
                  child: const Text(
                    "ดูทั้งหมด >",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Events')
                .doc(activeProject['id'])
                .collection('tasks')
                .where('isDone', isEqualTo: false)
                .snapshots(),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (taskSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'เกิดข้อผิดพลาดในการโหลดงาน: ${taskSnapshot.error}',
                    ),
                  ),
                );
              }
              if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.post_add,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "ยังไม่มีงานในโครงงานนี้",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "เริ่มต้นจัดการงานของคุณโดยการสร้างงานแรก",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _activeNavIndex = 2; // Go to TaskBoardScreen
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("สร้างงานแรกของคุณ"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort tasks by due date (ascending) and take the first 3
              final tasks = taskSnapshot.data!.docs.toList();
              tasks.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aDate = aData['dueDate'] as Timestamp?;
                final bDate = bData['dueDate'] as Timestamp?;
                if (aDate == null) {
                  return 1; // Put tasks without due date at the end
                }
                if (bDate == null) {
                  return -1;
                }
                return aDate.compareTo(bDate);
              });

              final displayTasks = tasks.take(3).toList();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTasks.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final taskDoc = displayTasks[index];
                    final taskData = taskDoc.data() as Map<String, dynamic>;
                    final dueDateTimestamp = taskData['dueDate'] as Timestamp?;
                    final DateTime? dueDate = dueDateTimestamp?.toDate();
                    final bool isDone = taskData['isDone'] ?? false;
                    final bool isOverdue =
                        dueDate != null &&
                        !isDone &&
                        dueDate.isBefore(DateUtils.dateOnly(DateTime.now()));

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isDone,
                              activeColor: const Color(0xFF4F46E5),
                              onChanged: (val) {
                                taskDoc.reference.update({'isDone': val});
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              taskData['title'] ?? 'ไม่มีชื่องาน',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? Colors.grey[400]
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 12,
                                    color: isOverdue
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${dueDate.day}/${dueDate.month}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isOverdue
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF64748B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              "เมนูลัดสำหรับคุณ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _buildQuickActionCard(
                  "📋",
                  "บอร์ดงาน",
                  onTap: () => setState(() => _activeNavIndex = 2),
                ),
                _buildQuickActionCard(
                  "💬",
                  "แชทกลุ่ม",
                  onTap: () => setState(() => _activeNavIndex = 3),
                ),
                _buildQuickActionCard(
                  "🧑‍🤝‍🧑",
                  "เชิญเพื่อน",
                  onTap: () {
                    _showInviteFriendDialog(activeProject['inviteCode']);
                  },
                ),
                _buildQuickActionCard("✨", "เร็วๆ นี้", isEnabled: false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTeamMembersSection(activeProject),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Map<String, dynamic> userData) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // วาดภาพจำลองกระเป๋าว่างเปล่า/โฟลเดอร์สูง 200px
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 90,
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "🎒 Empty Bag",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // "ยังไม่มีโครงงาน" (18px ตัวหนา กึ่งกลาง)
            const Text(
              "ยังไม่มีโครงงาน",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            // "เริ่มสร้างโครงงานแรกของคุณ" (14px สีเทา กึ่งกลาง)
            const Text(
              "เริ่มสร้างโครงงานแรกของคุณ เพื่อเริ่มบันทึกกิจกรรม และพัฒนาไอเดียของคุณสู่ความจริง",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // ปุ่มสร้างโครงงานใหม่เต็มความกว้าง
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateProjectBottomSheet(userData),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  "สร้างโครงงานใหม่",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _showJoinProjectDialog(userData),
                icon: const Icon(Icons.group_add_outlined),
                label: const Text(
                  "เข้าร่วมโครงงาน",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectBottomSheet(Map<String, dynamic> userData) {
    String localType = "NSC";
    final ctrlTh = TextEditingController(text: "");
    final ctrlEn = TextEditingController(text: "");
    DateTimeRange? localRange;
    bool isLoadingInSheet = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // ดันจอหนีแป้นพิมพ์คีย์บอร์ด
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Drag handle เส้นจำลองตรงกลางด้านบน
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // 2. หัวข้อใหญ่และปุ่ม Close ปิดแบบปิดกากบาท
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "สร้างโครงงานใหม่",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Input: ชื่อโครงงานไทย
                    const Text(
                      "ชื่อโครงงาน (ภาษาไทย)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrlTh,
                      decoration: InputDecoration(
                        hintText: "กรอกชื่อโครงงานภาษาไทย...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Input: ชื่อโครงงานอังกฤษ
                    const Text(
                      "ชื่อโครงงาน (ภาษาอังกฤษ)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrlEn,
                      decoration: InputDecoration(
                        hintText: "Project name in English...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Dropdown เลือกกลุ่มประเภทโครงงาน
                    const Text(
                      "ประเภทโครงงาน",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: localType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      items: ["NSC", "วิทยาศาสตร์", "สังคม", "ทั่วไป"].map((
                        type,
                      ) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => localType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 6. Date Range Picker ในการสลับช่วงเวลา
                    const Text(
                      "ระยะเวลาดำเนินโครงงาน",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          initialDateRange: localRange,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => localRange = picked);
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
                              localRange == null
                                  ? "คลิกเลือกช่วงเวลา..."
                                  : "${localRange!.start.day}/${localRange!.start.month}/${localRange!.start.year} - ${localRange!.end.day}/${localRange!.end.month}/${localRange!.end.year}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(
                              Icons.date_range,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7. ปุ่มคู่ "ยกเลิก" และ "สร้าง"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.42,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isLoadingInSheet
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.42,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoadingInSheet
                                ? null
                                : () async {
                                    debugPrint(
                                      "--- [1] 'สร้าง' button pressed ---",
                                    );
                                    setModalState(
                                      () => isLoadingInSheet = true,
                                    );

                                    if (ctrlTh.text.isEmpty ||
                                        localRange == null) {
                                      debugPrint(
                                        "--- [!] Validation failed: Project name or date range is missing.",
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'กรุณากรอกชื่อโครงงานและเลือกระยะเวลา',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      setModalState(
                                        () => isLoadingInSheet = false,
                                      );
                                      return;
                                    }

                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      debugPrint(
                                        "--- [!] Error: User is not authenticated.",
                                      );
                                      setModalState(
                                        () => isLoadingInSheet = false,
                                      );
                                      return;
                                    }
                                    debugPrint(
                                      "--- [2] User is authenticated: ${user.uid} ---",
                                    );

                                    final newProjectData = {
                                      'name_th': ctrlTh.text.trim(),
                                      'name_en': ctrlEn.text.trim(),
                                      'type': localType,
                                      'startDate': Timestamp.fromDate(
                                        localRange!.start,
                                      ),
                                      'endDate': Timestamp.fromDate(
                                        localRange!.end,
                                      ),
                                      'inviteCode': _generateInviteCode(),
                                      'ownerUid': user.uid,
                                      'memberUids': [user.uid],
                                      'createdAt': FieldValue.serverTimestamp(),
                                      'members': [
                                        {
                                          'uid': user.uid,
                                          'name': userData['name'],
                                          'emoji': userData['avatarEmoji'],
                                          'role': userData['role'],
                                        },
                                      ],
                                    };

                                    debugPrint(
                                      "--- [3] Preparing to upload data: $newProjectData ---",
                                    );

                                    try {
                                      final newProjectRef = await FirebaseFirestore.instance
                                          .collection('Events')
                                          .add(newProjectData);
                                      debugPrint(
                                        "--- [4] SUCCESS: Data uploaded to Firestore! ID: ${newProjectRef.id} ---",
                                      );

                                      // Create tasks from the template
                                      debugPrint(
                                        "--- [5] PREPARE: Calling createTasksFromTemplate for type: '$localType' ---",
                                      );
                                      await ProjectTemplates.createTasksFromTemplate(
                                        newProjectRef.id,
                                        localType,
                                      );
                                      debugPrint(
                                        "--- [6] SUCCESS: Finished createTasksFromTemplate call. ---",
                                      );

                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'สร้างโครงงานสำเร็จเรียบร้อย!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint(
                                        "--- [!] FIREBASE ERROR: $e ---",
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('เกิดข้อผิดพลาด: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setModalState(
                                          () => isLoadingInSheet = false,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoadingInSheet
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "สร้าง",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProjectSelectionDropdown(
    List<QueryDocumentSnapshot> projects,
    Map<String, dynamic> userData,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'เลือกโครงงาน',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: projects.length + 1, // +1 for "Create New"
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                if (index == projects.length) {
                  // Last item is the "Create New Project" button
                  return ListTile(
                    leading: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4F46E5),
                    ),
                    title: const Text(
                      "สร้างโครงงานใหม่",
                      style: TextStyle(fontSize: 14, color: Color(0xFF4F46E5)),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the selection dialog
                      _showCreateProjectBottomSheet(
                        userData,
                      ); // Open the create sheet
                    },
                  );
                }

                final projectDoc = projects[index];
                final projectData = projectDoc.data() as Map<String, dynamic>;
                final projectName =
                    projectData['name_th'] ?? 'โครงงานไม่มีชื่อ';
                return ListTile(
                  leading: const Icon(
                    Icons.folder_outlined,
                    color: Color(0xFF64748B),
                  ),
                  title: Text(
                    projectName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    tooltip: 'ลบโครงงาน',
                    onPressed: () {
                      Navigator.pop(context); // Close the selection dialog
                      _deleteProject(projectDoc.id, projectName);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _activeProjectId = projectDoc.id;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
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
                              final List<dynamic> memberUids =
                                  projectDoc.data()['memberUids'] ?? [];

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
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('เข้าร่วมโครงงานสำเร็จ!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
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

  void _showInviteFriendDialog(String inviteCode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.group_add_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'เชิญเพื่อนเข้าร่วม',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'แชร์โค้ดนี้ให้เพื่อนของคุณเพื่อเข้าร่วมโครงงาน',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteCode));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('คัดลอกโค้ดเชิญแล้ว!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('คัดลอกโค้ด'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamMembersSection(Map<String, dynamic> activeProject) {
    final List<dynamic> memberUids = activeProject['memberUids'] ?? [];
    final String ownerUid = activeProject['ownerUid'] ?? '';

    if (memberUids.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there are no members
    }

    // Firestore 'whereIn' query supports a maximum of 30 elements for streams.
    final List<dynamic> queryableUids = memberUids.length > 30
        ? memberUids.sublist(0, 30)
        : memberUids;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "สมาชิกในทีม",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: queryableUids)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('ไม่พบข้อมูลสมาชิก'),
              );
            }

            // Sort members to put teachers first, then the owner
            final members = snapshot.data!.docs.toList();
            members.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aIsTeacher = (aData['role'] ?? 'student') == 'teacher';
              final bIsTeacher = (bData['role'] ?? 'student') == 'teacher';
              final aIsOwner = a.id == ownerUid;
              final bIsOwner = b.id == ownerUid;

              if (aIsTeacher && !bIsTeacher) return -1;
              if (!aIsTeacher && bIsTeacher) return 1;

              if (aIsOwner && !bIsOwner) return -1;
              if (!aIsOwner && bIsOwner) return 1;

              final aName = aData['name'] ?? '';
              final bName = bData['name'] ?? '';
              return aName.compareTo(bName);
            });

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final memberData =
                        members[index].data() as Map<String, dynamic>;
                    final String name = memberData['name'] ?? 'ไม่มีชื่อ';
                    final String email = memberData['email'] ?? 'ไม่มีอีเมล';
                    final String emoji = memberData['avatarEmoji'] ?? '🧑‍💻';
                    final bool isOwner = members[index].id == ownerUid;
                    final String role = memberData['role'] ?? 'student';
                    final bool isTeacher = role == 'teacher';

                    List<Widget> trailingBadges = [];

                    if (isTeacher) {
                      trailingBadges.add(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2), // red-100
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ครูที่ปรึกษา',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB91C1C), // red-700
                            ),
                          ),
                        ),
                      );
                    }

                    if (isOwner) {
                      if (trailingBadges.isNotEmpty) {
                        trailingBadges.add(const SizedBox(width: 4));
                      }
                      trailingBadges.add(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7), // yellow-100
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ผู้สร้าง',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E), // yellow-800
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      color: isTeacher ? const Color(0xFFFEF2F2) : null,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: trailingBadges.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: trailingBadges,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deleteProject(String projectId, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบโครงงาน'),
        content: Text(
          'คุณต้องการลบโครงงาน "$projectName" ใช่หรือไม่? การกระทำนี้จะลบข้อมูลและงานทั้งหมดที่เกี่ยวข้องอย่างถาวร',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยันลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('กำลังลบโครงงาน "$projectName"...')));

    final firestore = FirebaseFirestore.instance;
    final projectRef = firestore.collection('Events').doc(projectId);

    try {
      // Delete all tasks in the 'tasks' subcollection
      final tasksSnapshot = await projectRef.collection('tasks').get();
      if (tasksSnapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final taskDoc in tasksSnapshot.docs) {
          batch.delete(taskDoc.reference);
        }
        await batch.commit();
      }

      // Delete the project document itself
      await projectRef.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบโครงงาน "$projectName" สำเร็จแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการลบโครงงาน: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildQuickActionCard(
    String icon,
    String title, {
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
          border: isEnabled ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isEnabled
                    ? const Color(0xFF1E293B)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ที่แยกออกมาเพื่อความสะอาด ---

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool hasProject,
    String projectTitle,
    String userAvatar,
    List<QueryDocumentSnapshot> projects,
    Map<String, dynamic> userData,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: hasProject
                    ? () => _showProjectSelectionDropdown(projects, userData)
                    : null,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        projectTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (hasProject)
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.group_add_outlined,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'เข้าร่วมโครงงาน',
                  onPressed: () {
                    _showJoinProjectDialog(userData);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeNavIndex = 4;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
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
              ],
            ),
          ],
        ),
      ),
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
          _buildNavItem(1, Icons.school_rounded, "Learn"),
          _buildNavItem(2, Icons.assignment_rounded, "Tasks"),
          _buildNavItem(3, Icons.chat_bubble_rounded, "Chat"),
          _buildNavItem(4, Icons.person_rounded, "Profile"),
        ],
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
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
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
}

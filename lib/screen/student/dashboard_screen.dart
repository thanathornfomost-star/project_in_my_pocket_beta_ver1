import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_in_my_pocket_beta_ver1/main.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/learn_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/profile_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/chat_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/project_plan_screen.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/student/task_board_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeNavIndex = 0;
  // ลำดับเมนูด้านล่างสุด (0: Home, 1: Learn, 2: Tasks, 3: Chat, 4: Profile)
  bool _hasProject = true; // Mock state: true = has project, false = empty
  String _projectHealth = 'safe'; // safe, warning, late

  // ข้อมูลโครงงานเริ่มต้นสำหรับการนำเสนอ
  Map<String, dynamic> _activeProject = {
    'id': 'proj1',
    'name_th': "โครงงานพัฒนาโมบายแอปพลิเคชันเพื่อการศึกษา",
    'name_en': "Mobile App for Education",
    'type': 'NSC',
    'inviteCode': 'PJM-AB12CD',
  };

  // รายการงานสัปดาห์นี้
  final List<Map<String, dynamic>> _weeklyTasks = [
    {
      "title": "สรุปบทที่ 3",
      "date": "25 มิ.ย.",
      "isOverdue": false,
      "isDone": false,
    },
    {
      "title": "ร่วมวัตถุประสงค์ (วิชาเอก)",
      "date": "24 มิ.ย.",
      "isOverdue": false,
      "isDone": false,
    },
    {
      "title": "สรุปผลทดลองที่ 1",
      "date": "20 มิ.ย.",
      "isOverdue": true,
      "isDone": true,
    },
  ];

  // รายชื่อโครงงานทั้งหมดที่มีจำลองสำหรับการสลับ
  final List<String> _myProjects = [
    "โครงงานพัฒนาโมบายแอปพลิเคชันเพื่อการศึกษา",
    "ระบบคลังความรู้อัจฉริยะในสถานศึกษา",
    "อุปกรณ์ IoT ตรวจจับความชื้นในดินและพืช",
  ];

  // Mock user data
  final Map<String, dynamic> _userData = {'avatarEmoji': '🧑‍💻'};

  Color _getHealthBgColor() {
    switch (_projectHealth) {
      case 'safe':
        return const Color(0xFFDCFCE7); // เขียวอ่อน
      case 'warning':
        return const Color(0xFFFEF3C7); // เหลืองอ่อน
      case 'late':
        return const Color(0xFFFEE2E2); // แดงอ่อน
      default:
        return const Color(0xFFDCFCE7);
    }
  }

  Color _getHealthTextColor() {
    switch (_projectHealth) {
      case 'safe':
        return const Color(0xFF15803D); // เขียวเข้ม
      case 'warning':
        return const Color(0xFFB45309); // เหลืองเข้ม
      case 'late':
        return const Color(0xFFB91C1C); // แดงเข้ม
      default:
        return const Color(0xFF15803D);
    }
  }

  String _getHealthText() {
    switch (_projectHealth) {
      case 'safe':
        return "ปลอดภัย (ตาม Milestone)";
      case 'warning':
        return "ควรเร่ง (เลยกำหนดบางส่วน)";
      case 'late':
        return "ล่าช้า (จำเป็นต้องปรับแผนใหม่)";
      default:
        return "ปลอดภัย (ตาม Milestone)";
    }
  }

  IconData _getHealthIcon() {
    switch (_projectHealth) {
      case 'safe':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'late':
        return Icons.error_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'PJM-${String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))))}';
  }

  // Widget สำหรับแสดงผลตามเมนูที่เลือก
  Widget _buildPageForIndex(int index) {
    switch (index) {
      case 0:
        return _hasProject ? _buildActiveState() : _buildEmptyState();
      case 1:
        return const LearnScreen(); // แสดงหน้าคลังความรู้
      case 2:
        return _hasProject
            ? const TaskBoardScreen()
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
        return _hasProject
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
        return _hasProject ? _buildActiveState() : _buildEmptyState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // 1. TOP APP BAR (สูง 56px, fixed บนสุด)
      appBar: _buildAppBar(
        context,
        _hasProject,
        _activeProject['name_th'] ?? 'ยังไม่มีโครงงาน',
        _userData['avatarEmoji'],
      ),

      // จัดการหน้าจอตามสถานะว่ามีโปรเจกต์หรือไม่
      body: _buildPageForIndex(_activeNavIndex),

      // 4. BOTTOM NAVIGATION BAR (fixed ล่างสุด, height 64px)
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildActiveState() {
    final totalTasks = _weeklyTasks.length;
    final doneTasks = _weeklyTasks
        .where((task) => task['isDone'] == true)
        .length;
    final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD: Project Health (margin 16px, padding 16px, border-radius 16px)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getHealthBgColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getHealthTextColor().withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getHealthIcon(),
                      color: _getHealthTextColor(),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getHealthText(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getHealthTextColor(),
                      ),
                    ),
                  ],
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
                            backgroundColor: _getHealthTextColor().withValues(
                              alpha: 0.15,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getHealthTextColor(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getHealthTextColor(),
                      ),
                    ),
                  ],
                ),
              ],
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

          if (_weeklyTasks.where((t) => t['isDone'] == false).isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "🎉 ยอดเยี่ยม! ไม่มีงานค้างเลย",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Container(
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
                itemCount: _weeklyTasks.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final task = _weeklyTasks[index];
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
                            value: task['isDone'],
                            activeColor: const Color(0xFF4F46E5),
                            onChanged: (val) {
                              setState(() {
                                task['isDone'] = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task['title'],
                            style: TextStyle(
                              fontSize: 14,
                              decoration: task['isDone']
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task['isDone']
                                  ? Colors.grey[400]
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: task['isOverdue'] && !task['isDone']
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 12,
                                color: task['isOverdue'] && !task['isDone']
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task['date'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: task['isOverdue'] && !task['isDone']
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
                  "✏️",
                  "เขียนแผน",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectPlanScreen(),
                      ),
                    );
                  },
                ),
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
                    _showInviteFriendDialog(_activeProject['inviteCode']);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                onPressed: _showCreateProjectBottomSheet,
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
                onPressed: _showJoinProjectDialog,
                icon: const Icon(Icons.group_add_outlined),
                label: const Text(
                  "เข้าร่วมโครงงาน",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
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

  void _showCreateProjectBottomSheet() {
    String localType = "NSC";
    final ctrlTh = TextEditingController(text: "");
    final ctrlEn = TextEditingController(text: "");
    DateTimeRange? localRange;

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
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: () {
                              if (ctrlTh.text.isEmpty || localRange == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'กรุณากรอกชื่อโครงงานและเลือกระยะเวลา',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _activeProject = {
                                  'id':
                                      'proj_new_${DateTime.now().millisecond}',
                                  'name_th': ctrlTh.text,
                                  'name_en': ctrlEn.text,
                                  'inviteCode': _generateInviteCode(),
                                };
                                _hasProject = true;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('สร้างโครงงานสำเร็จเรียบร้อย!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "สร้าง",
                              style: TextStyle(fontWeight: FontWeight.bold),
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

  void _showProjectSelectionDropdown() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'เลือกโครงงานที่มีอยู่',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _myProjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.folder, color: Color(0xFF4F46E5)),
                  title: Text(
                    _myProjects[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    setState(() {
                      _activeProject['name_th'] = _myProjects[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _showDemoControlPanel() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🛠️ แผงทดสอบจำลองข้อมูล (สำหรับส่งประกวด/ตรวจงาน)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Divider(),
              // ... (rest of the demo panel code)
            ],
          ),
        );
      },
    );
  }

  void _showJoinProjectDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
                'กรอกโค้ดเชิญที่ได้รับจากเพื่อน เพื่อเข้าร่วมทีม (Mockup)',
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
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  setState(() {
                    _hasProject = true;
                    _activeProject['name_th'] = "โครงงานที่เข้าร่วม (Mock)";
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เข้าร่วมโครงงานสำเร็จ!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('เข้าร่วม'),
            ),
          ],
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
              Icon(Icons.group_add_outlined, color: AppColors.primary),
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

  // --- WIDGETS ที่แยกออกมาเพื่อความสะอาด ---

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool hasProject,
    String projectTitle,
    String userAvatar,
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
                onTap: hasProject ? _showProjectSelectionDropdown : null,
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

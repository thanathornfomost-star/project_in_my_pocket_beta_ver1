import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Helper Function for File Upload & Launch ---

Future<void> _pickAndUploadAttachment({
  required BuildContext context,
  required String projectId,
  required DocumentReference taskRef,
}) async {
  try {
    // แก้ไข: เรียกใช้ FilePicker ผ่าน FilePicker.platform
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: kIsWeb, // ใช้ Data bytes บน Web
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final fileName = file.name;
    final destination = 'projects/$projectId/tasks/${taskRef.id}/$fileName';

    final ref = FirebaseStorage.instance.ref(destination);
    UploadTask uploadTask;

    if (kIsWeb || file.bytes != null) {
      uploadTask = ref.putData(file.bytes!);
    } else if (file.path != null) {
      uploadTask = ref.putFile(File(file.path!));
    } else {
      throw Exception('ไม่สามารถอ่านไฟล์ได้');
    }

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final newAttachment = {
      'name': fileName,
      'url': downloadUrl,
      'uploadedAt': Timestamp.now(),
    };

    await taskRef.update({
      'attachments': FieldValue.arrayUnion([newAttachment]),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('แนบไฟล์เรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการแนบไฟล์: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _openAttachmentUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $url");
  }
}

// Widget สำหรับแสดงรายการไฟล์แนบ
Widget _buildAttachmentsList({
  required BuildContext context,
  required String projectId,
  required DocumentSnapshot taskDoc,
  required List<dynamic> attachments,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'ไฟล์แนบ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _pickAndUploadAttachment(
              context: context,
              projectId: projectId,
              taskRef: taskDoc.reference,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '+ เพิ่มไฟล์',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      if (attachments.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Text(
            'ยังไม่มีไฟล์แนบ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
      else
        // แก้ไข: ตัด .toList() ที่ซ้ำซ้อนกับการสเปรด (...) ออก
        ...attachments.map((attachment) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(
            attachment as Map,
          );
          final String name = item['name'] ?? 'ไฟล์แนบ';
          final String url = item['url'] ?? '';

          return InkWell(
            onTap: () => _openAttachmentUrl(url),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
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
        }),
    ],
  );
}

// --- Data Models ---

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

class _TaskBoardScreenState extends State<TaskBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Member> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTeamMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeamMembers() async {
    try {
      final projectDoc = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.projectId)
          .get();
      if (projectDoc.exists && mounted) {
        final membersData =
            (projectDoc.data()?['members'] as List<dynamic>?) ?? [];
        setState(() {
          _teamMembers = membersData.map((m) => Member.fromMap(m)).toList();
        });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'บอร์ดโครงงาน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'เอกสาร'),
            Tab(text: 'สิ่งที่ต้องทำ'),
          ],
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Events')
            .doc(widget.projectId)
            .collection('tasks')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final allTasks = snapshot.data?.docs ?? [];

          allTasks.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aOrder = aData['order'] as int?;
            final bOrder = bData['order'] as int?;

            if (aOrder != null && bOrder != null) {
              return aOrder.compareTo(bOrder);
            }
            if (aOrder != null) return -1;
            if (bOrder != null) return 1;
            return 0;
          });

          final templateTasks = allTasks.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isTemplate'] == true;
          }).toList();

          final userTasks = allTasks.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isTemplate'] != true;
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _DocumentTasksView(
                templateTasks: templateTasks,
                projectId: widget.projectId,
                teamMembers: _teamMembers,
              ),
              _UserTasksView(
                userTasks: userTasks,
                projectId: widget.projectId,
                teamMembers: _teamMembers,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(
          context,
          projectId: widget.projectId,
          teamMembers: _teamMembers,
        ),
        backgroundColor: const Color(0xFF4F46E5),
        tooltip: 'เพิ่มงานใหม่',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- Tab View for Template Documents ---

class _DocumentTasksView extends StatelessWidget {
  final String projectId;
  final List<DocumentSnapshot> templateTasks;
  final List<Member> teamMembers;

  const _DocumentTasksView({
    required this.projectId,
    required this.templateTasks,
    required this.teamMembers,
  });

  Map<DocumentSnapshot, List<DocumentSnapshot>> _groupTasks(
    List<DocumentSnapshot> tasks,
  ) {
    final Map<DocumentSnapshot, List<DocumentSnapshot>> chapters = {};
    DocumentSnapshot? currentChapter;

    for (final task in tasks) {
      final taskData = task.data() as Map<String, dynamic>;
      if (taskData['isChapter'] == true) {
        currentChapter = task;
        chapters[currentChapter] = [];
      } else if (currentChapter != null) {
        chapters[currentChapter]?.add(task);
      }
    }
    return chapters;
  }

  @override
  Widget build(BuildContext context) {
    if (templateTasks.isEmpty) {
      return const Center(
        child: Text('ไม่พบรายการเอกสาร', style: TextStyle(color: Colors.grey)),
      );
    }

    final groupedTasks = _groupTasks(templateTasks);

    return ListView(
      padding: const EdgeInsets.all(8),
      children: groupedTasks.entries.map((entry) {
        final chapterDoc = entry.key;
        final chapterData = chapterDoc.data() as Map<String, dynamic>;
        final subTasks = entry.value;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chapterData['title'] ?? 'บท',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF4F46E5)),
                  onPressed: () {
                    _showAddTaskDialog(
                      context,
                      projectId: projectId,
                      teamMembers: teamMembers,
                      parentChapterId: chapterDoc.id,
                    );
                  },
                ),
              ],
            ),
            children: subTasks
                .map(
                  (subTaskDoc) => _TemplateTaskTile(
                    taskDoc: subTaskDoc,
                    projectId: projectId,
                    teamMembers: teamMembers,
                  ),
                )
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}

// --- Tile for a single sub-task in the document view ---

class _TemplateTaskTile extends StatelessWidget {
  final DocumentSnapshot taskDoc;
  final String projectId;
  final List<Member> teamMembers;

  const _TemplateTaskTile({
    required this.taskDoc,
    required this.projectId,
    required this.teamMembers,
  });

  @override
  Widget build(BuildContext context) {
    final taskData = taskDoc.data() as Map<String, dynamic>;
    final bool isDone = taskData['isDone'] ?? false;
    final assignedTo = taskData['assignedTo'] != null
        ? Member.fromMap(taskData['assignedTo'])
        : null;
    final dueDate = (taskData['dueDate'] as Timestamp?)?.toDate();
    final List<dynamic> attachments = taskData['attachments'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isDone,
                onChanged: (val) => taskDoc.reference.update({'isDone': val}),
                activeColor: const Color(0xFF4F46E5),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskData['title'] ?? 'ไม่มีชื่องาน',
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (assignedTo != null)
                CircleAvatar(
                  radius: 14,
                  // แก้ไข: เปลี่ยนกับ withValues(alpha: ...) แทน withOpacity
                  backgroundColor: const Color(
                    0xFF4F46E5,
                  ).withValues(alpha: 0.2),
                  child: Text(
                    assignedTo.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              else
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black12,
                  child: Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              IconButton(
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => _pickAndUploadAttachment(
                  context: context,
                  projectId: projectId,
                  taskRef: taskDoc.reference,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => _showEditTaskDialog(
                  context,
                  taskDoc: taskDoc,
                  projectId: projectId,
                  teamMembers: teamMembers,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 48.0,
              right: 12.0,
              bottom: 8.0,
            ),
            child: _buildAttachmentsList(
              context: context,
              projectId: projectId,
              taskDoc: taskDoc,
              attachments: attachments,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// --- Tab View for User-created Tasks ---

class _UserTasksView extends StatelessWidget {
  final String projectId;
  final List<DocumentSnapshot> userTasks;
  final List<Member> teamMembers;

  const _UserTasksView({
    required this.projectId,
    required this.userTasks,
    required this.teamMembers,
  });

  @override
  Widget build(BuildContext context) {
    if (userTasks.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีงาน\nกดปุ่ม + เพื่อเพิ่มงาน',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final chapters = userTasks.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['isChapter'] == true;
    }).toList();

    final chapterMap = {for (var c in chapters) c.id: c};

    final Map<DocumentSnapshot, List<DocumentSnapshot>> groupedTasks = {
      for (var c in chapters) c: [],
    };

    final List<DocumentSnapshot> customUserTasks = [];
    DocumentSnapshot? lastSeenChapter;

    for (final task in userTasks) {
      final taskData = task.data() as Map<String, dynamic>;

      if (taskData['isChapter'] == true) {
        lastSeenChapter = task;
        continue;
      }

      final parentId = taskData['parentChapterId'] as String?;

      if (parentId != null) {
        final parentChapter = chapterMap[parentId];
        if (parentChapter != null) {
          groupedTasks[parentChapter]!.add(task);
        } else {
          customUserTasks.add(task);
        }
      } else if (taskData['isGeneralTemplate'] == true) {
        if (lastSeenChapter != null) {
          groupedTasks[lastSeenChapter]!.add(task);
        } else {
          customUserTasks.add(task);
        }
      } else {
        customUserTasks.add(task);
      }
    }

    final sortedGroupedEntries = groupedTasks.entries.toList()
      ..sort((a, b) {
        final aData = a.key.data() as Map<String, dynamic>;
        final bData = b.key.data() as Map<String, dynamic>;
        final aOrder = aData['order'] as int?;
        final bOrder = bData['order'] as int?;
        if (aOrder != null && bOrder != null) {
          return aOrder.compareTo(bOrder);
        }
        return 0;
      });

    for (var entry in sortedGroupedEntries) {
      entry.value.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aIsTemplate = aData['isGeneralTemplate'] == true;
        final bIsTemplate = bData['isGeneralTemplate'] == true;

        if (aIsTemplate && !bIsTemplate) return -1;
        if (!aIsTemplate && bIsTemplate) return 1;

        if (aIsTemplate) {
          final aOrder = aData['order'] as int?;
          final bOrder = bData['order'] as int?;
          if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);
        }

        final aTimestamp = aData['createdAt'] as Timestamp?;
        final bTimestamp = bData['createdAt'] as Timestamp?;
        if (aTimestamp != null && bTimestamp != null) {
          return aTimestamp.compareTo(bTimestamp);
        }
        return 0;
      });
    }

    customUserTasks.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aIsDone = aData['isDone'] ?? false;
      final bIsDone = bData['isDone'] ?? false;
      final aDate = aData['dueDate'] as Timestamp?;
      final bDate = bData['dueDate'] as Timestamp?;

      if (aIsDone != bIsDone) return aIsDone ? 1 : -1;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sortedGroupedEntries.isNotEmpty) ...[
            ...sortedGroupedEntries.map((entry) {
              final chapterDoc = entry.key;
              final chapterData = chapterDoc.data() as Map<String, dynamic>;
              final subTasks = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chapterData['title'] ?? 'บท',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF4F46E5)),
                        onPressed: () {
                          _showAddTaskDialog(
                            context,
                            projectId: projectId,
                            teamMembers: teamMembers,
                            parentChapterId: chapterDoc.id,
                          );
                        },
                      ),
                    ],
                  ),
                  children: subTasks.map((subTaskDoc) {
                    return _UserTaskListItem(
                      taskDoc: subTaskDoc,
                      teamMembers: teamMembers,
                      projectId: projectId,
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (customUserTasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 8, left: 4, right: 4),
              child: Text(
                'งานที่สร้างเพิ่มเติม',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...customUserTasks.map((taskDoc) {
              return _UserTaskListItem(
                taskDoc: taskDoc,
                teamMembers: teamMembers,
                projectId: projectId,
              );
            }),
          ],
        ],
      ),
    );
  }
}

// --- List Item for a user-created task ---

class _UserTaskListItem extends StatelessWidget {
  final DocumentSnapshot taskDoc;
  final List<Member> teamMembers;
  final String projectId;

  const _UserTaskListItem({
    required this.taskDoc,
    required this.teamMembers,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final taskData = taskDoc.data() as Map<String, dynamic>;
    final bool isDone = taskData['isDone'] ?? false;
    final DateTime? dueDate = (taskData['dueDate'] as Timestamp?)?.toDate();
    final bool isOverdue =
        dueDate != null && !isDone && dueDate.isBefore(DateTime.now());
    final Map<String, dynamic>? assignedToData =
        taskData['assignedTo'] as Map<String, dynamic>?;
    final List<dynamic> attachments = taskData['attachments'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      // แก้ไข: เปลี่ยนใช้ withValues(alpha: ...) แทน withOpacity
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: (val) async {
                    await taskDoc.reference.update({'isDone': val});
                    final parentChapterId =
                        taskData['parentChapterId'] as String?;
                    if (parentChapterId != null) {
                      _checkAndToggleParentChapter(projectId, parentChapterId);
                    }
                  },
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
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isOverdue
                                  ? Colors.red.shade700
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue
                                    ? Colors.red.shade700
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (assignedToData != null)
                  CircleAvatar(
                    radius: 16,
                    // แก้ไข: เปลี่ยนใช้ withValues(alpha: ...)
                    backgroundColor: const Color(
                      0xFF4F46E5,
                    ).withValues(alpha: 0.2),
                    child: Text(
                      assignedToData['emoji'] ?? '?',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black12,
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => _pickAndUploadAttachment(
                    context: context,
                    projectId: projectId,
                    taskRef: taskDoc.reference,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    _showEditTaskDialog(
                      context,
                      taskDoc: taskDoc,
                      projectId: projectId,
                      teamMembers: teamMembers,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: _buildAttachmentsList(
                context: context,
                projectId: projectId,
                taskDoc: taskDoc,
                attachments: attachments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dialog Functions ---

void _showAddTaskDialog(
  BuildContext context, {
  required String projectId,
  required List<Member> teamMembers,
  String? parentChapterId,
}) {
  _showTaskFormDialog(
    context,
    projectId: projectId,
    teamMembers: teamMembers,
    parentChapterId: parentChapterId,
  );
}

void _showEditTaskDialog(
  BuildContext context, {
  required DocumentSnapshot taskDoc,
  required String projectId,
  required List<Member> teamMembers,
}) {
  final taskData = taskDoc.data() as Map<String, dynamic>;
  final String? parentChapterId = taskData['parentChapterId'] as String?;

  _showTaskFormDialog(
    context,
    taskDoc: taskDoc,
    projectId: projectId,
    teamMembers: teamMembers,
    parentChapterId: parentChapterId,
  );
}

void _showTaskFormDialog(
  BuildContext context, {
  DocumentSnapshot? taskDoc,
  required String projectId,
  required List<Member> teamMembers,
  String? parentChapterId,
}) {
  final bool isEditing = taskDoc != null;
  final taskData = isEditing ? taskDoc.data() as Map<String, dynamic> : null;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: taskData?['title']);
  DateTime? selectedDate = (taskData?['dueDate'] as Timestamp?)?.toDate();
  Member? selectedMember;
  if (taskData?['assignedTo'] != null && teamMembers.isNotEmpty) {
    try {
      selectedMember = teamMembers.firstWhere(
        (m) => m.id == taskData!['assignedTo']['uid'],
      );
    } catch (e) {
      selectedMember = null;
    }
  }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? "แก้ไขงาน" : "สร้างงานใหม่",
                        style: const TextStyle(
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
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'ชื่องาน',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'กรุณาใส่ชื่องาน'
                        : null,
                  ),
                  const SizedBox(height: 16),
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
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
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
                            selectedDate != null
                                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                : "ไม่ได้กำหนด",
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
                  const Text(
                    "มอบหมายให้",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Member>(
                    initialValue: selectedMember,
                    hint: const Text('เลือกสมาชิกในทีม'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    items: teamMembers
                        .map(
                          (m) => DropdownMenuItem<Member>(
                            value: m,
                            child: Row(
                              children: [
                                Text(
                                  m.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(m.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (m) => setModalState(() => selectedMember = m),
                  ),
                  const SizedBox(height: 24),
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
                              final data = {
                                'title': titleController.text.trim(),
                                'dueDate': selectedDate != null
                                    ? Timestamp.fromDate(selectedDate!)
                                    : null,
                                'assignedTo': selectedMember?.toMap(),
                                'isTemplate': taskData?['isTemplate'] ?? false,
                                'isChapter': taskData?['isChapter'] ?? false,
                                if (parentChapterId != null)
                                  'parentChapterId': parentChapterId,
                              };

                              try {
                                if (isEditing) {
                                  await taskDoc.reference.update(data);
                                } else {
                                  data['isDone'] = false;
                                  data['attachments'] = [];
                                  data['createdAt'] =
                                      FieldValue.serverTimestamp();
                                  await FirebaseFirestore.instance
                                      .collection('Events')
                                      .doc(projectId)
                                      .collection('tasks')
                                      .add(data);
                                  if (parentChapterId != null) {
                                    _checkAndToggleParentChapter(
                                      projectId,
                                      parentChapterId,
                                    );
                                  }
                                }
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
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
                          child: Text(
                            isEditing ? "บันทึก" : "สร้างงาน",
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

// --- Utility function to check and toggle parent chapter status ---
Future<void> _checkAndToggleParentChapter(
  String projectId,
  String parentChapterId,
) async {
  try {
    final subTasksSnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .doc(projectId)
        .collection('tasks')
        .where('parentChapterId', isEqualTo: parentChapterId)
        .get();

    if (subTasksSnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('Events')
          .doc(projectId)
          .collection('tasks')
          .doc(parentChapterId)
          .update({'isDone': false});
      return;
    }

    final allSubTasksDone = subTasksSnapshot.docs.every((doc) {
      final data = doc.data();
      return data['isDone'] == true;
    });

    await FirebaseFirestore.instance
        .collection('Events')
        .doc(projectId)
        .collection('tasks')
        .doc(parentChapterId)
        .update({'isDone': allSubTasksDone});
  } catch (e) {
    debugPrint("Error checking and toggling parent chapter: $e");
  }
}

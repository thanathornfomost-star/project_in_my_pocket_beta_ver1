import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProjectChatScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const StudentProjectChatScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<StudentProjectChatScreen> createState() =>
      _StudentProjectChatScreenState();
}

class _StudentProjectChatScreenState extends State<StudentProjectChatScreen> {
  final _messageController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .get();
    final userData = userDoc.data();

    if (userData == null) return; // ไม่พบข้อมูลผู้ใช้

    final messageText = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.projectId)
        .collection('messages')
        .add({
          'text': messageText,
          'createdAt': Timestamp.now(),
          'senderId': _currentUser.uid,
          'senderName': userData['name'] ?? 'ผู้ใช้ไม่มีชื่อ',
          'senderRole': userData['role'] ?? 'student',
          'senderEmoji': userData['avatarEmoji'] ?? '🧑‍💻',
        });
  }

  Widget _buildRoleBadge(String role) {
    if (role == 'teacher') {
      return const Text(
        ' (ที่ปรึกษา)',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return const Text(
        ' (นักเรียน)',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projectName), elevation: 1),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Events')
                  .doc(widget.projectId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("ยังไม่มีข้อความ เริ่มการสนทนาได้เลย!"),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == _currentUser?.uid;

                    final messageBubble = Container(
                      margin: EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                        left: isMe ? 64 : 0,
                        right: isMe ? 0 : 64,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF4F46E5)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isMe
                              ? const Radius.circular(12)
                              : const Radius.circular(0),
                          bottomRight: isMe
                              ? const Radius.circular(0)
                              : const Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        messageData['senderName'] ?? 'Unknown',
                                  ),
                                  WidgetSpan(
                                    child: _buildRoleBadge(
                                      messageData['senderRole'] ?? 'student',
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                ],
                              ),
                            ),
                          if (!isMe) const SizedBox(height: 4),
                          Text(
                            messageData['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: isMe
                          ? messageBubble
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    messageData['senderEmoji'] ?? '👤',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: messageBubble),
                              ],
                            ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อความ...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF4F46E5),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

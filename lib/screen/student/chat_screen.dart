import 'package:flutter/material.dart';

// --- Mock Data Models ---
class ChatUser {
  final String id;
  final String name;
  final String emoji;
  final String role; // 'student' or 'teacher'

  const ChatUser({
    required this.id,
    required this.name,
    required this.emoji,
    required this.role,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final ChatUser sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

// --- Main Chat Screen Widget ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- Mock Data ---
  static const _currentUser = ChatUser(
    id: '2',
    name: 'บ็อบ',
    emoji: '🧑‍💻',
    role: 'student',
  );

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      text: 'ทุกคนครับ สรุปบทที่ 3 ใครรับผิดชอบส่วนไหนบ้างครับ?',
      sender: const ChatUser(
        id: '1',
        name: 'อลิซ',
        emoji: '👩‍🎓',
        role: 'student',
      ),
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: 'm2',
      text: 'เดี๋ยวผมทำส่วน 3.1 กับ 3.2 ให้ครับ',
      sender: _currentUser,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    ChatMessage(
      id: 'm3',
      text: 'ดีมากครับ ถ้ามีปัญหาตรงไหนถามครูได้เลยนะ',
      sender: const ChatUser(
        id: '4',
        name: 'อ.เดวิด',
        emoji: '🧑‍🏫',
        role: 'teacher',
      ),
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: 'm4',
      text: 'ได้เลยครับอาจารย์!',
      sender: _currentUser,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ];

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
      sender: _currentUser,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
      _textController.clear();
    });

    // Scroll to the bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('แชทกลุ่มโครงงาน'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.sender.id == _currentUser.id;
                return _ChatBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const _ChatBubble({required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.sender.role == 'teacher'
        ? Colors
              .green
              .shade100 // Teacher's bubble color
        : isCurrentUser
        ? Theme.of(context).primaryColor.withOpacity(
            0.15,
          ) // Current user (student)
        : Colors.white; // Other students

    final textColor = message.sender.role == 'teacher'
        ? Colors.green.shade900
        : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: Text(
                message.sender.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          if (!isCurrentUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

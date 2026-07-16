import 'package:flutter/material.dart';

class AdvisorChatScreen extends StatelessWidget {
  const AdvisorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: Text(
          'หน้าแชทสำหรับอาจารย์',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

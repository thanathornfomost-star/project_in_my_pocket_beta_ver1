import 'package:flutter/material.dart';

/// Color constants
class AppColors {
  static const Color surface = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF757575);
}

/// หน้าจอหลักสำหรับแสดงรายการหัวข้อการเรียนรู้
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คลังความรู้'),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            // นี่คือ Widget ที่คุณสามารถคัดลอกไปใช้ซ้ำได้เลย
            LearningTopicCard(
              title: 'โครงการด้านสังคม',
              description: 'แนวทางการเขียนโครงการเพื่อพัฒนาสังคมและชุมชน',
              details:
                  'คำแนะนำสำหรับการเขียนโครงการด้านสังคม:\n\n1. ที่มาและความสำคัญ: อธิบายปัญหาสังคมที่ต้องการแก้ไข และทำไมโครงการนี้จึงสำคัญ\n\n2. วัตถุประสงค์: กำหนดเป้าหมายที่ชัดเจน วัดผลได้\n\n3. กลุ่มเป้าหมาย: ระบุว่าใครคือผู้ที่จะได้รับประโยชน์จากโครงการ\n\n4. การหาแหล่งอ้างอิง: ค้นหางานวิจัย สถิติ หรือบทความที่เกี่ยวข้องกับปัญหาสังคมนั้นๆ จากหน่วยงานภาครัฐ, NGO, หรือสถาบันการศึกษา',
            ),
            const SizedBox(height: 12),
            LearningTopicCard(
              title: 'โครงการ NSC',
              description: 'เคล็ดลับและแนวทางสำหรับเตรียมโครงการส่งประกวด NSC',
              details:
                  'คำแนะนำสำหรับโครงการ NSC:\n\n1. การเลือกหัวข้อ: ควรเป็นหัวข้อที่แปลกใหม่ มีนวัตกรรม และสามารถแก้ปัญหาได้จริง\n\n2. การเขียนเอกสาร: รูปเล่มรายงานต้องมีโครงสร้างตามที่ NSC กำหนด เช่น บทคัดย่อ, หลักการและทฤษฎี, วิธีการดำเนินงาน, ผลการทดลอง\n\n3. การใช้คำ: ใช้ศัพท์เทคนิคที่ถูกต้องและเหมาะสมกับหมวดหมู่ที่ลงแข่งขัน\n\n4. การหาแหล่งอ้างอิง: อ้างอิงถึงงานวิจัย (Research Papers) หรือโปรเจกต์อื่นๆ ที่เป็นแรงบันดาลใจ',
            ),
            const SizedBox(height: 12),
            LearningTopicCard(
              title: 'โครงการวิทยาศาสตร์',
              description:
                  'ขั้นตอนการทำโครงงานวิทยาศาสตร์ ตั้งแต่เริ่มต้นจนนำเสนอ',
              details:
                  'คำแนะนำสำหรับโครงการวิทยาศาสตร์:\n\n1. ตั้งสมมติฐาน: กำหนดคำถามที่ต้องการหาคำตอบผ่านการทดลอง\n\n2. ออกแบบการทดลอง: วางแผนการทดลองอย่างเป็นระบบ มีตัวแปรควบคุม ตัวแปรตาม และตัวแปรต้น\n\n3. การบันทึกและวิเคราะห์ผล: เก็บข้อมูลอย่างละเอียดและนำเสนอในรูปแบบของตารางหรือกราฟ\n\n4. การสรุปผล: ตอบสมมติฐานที่ตั้งไว้โดยใช้ข้อมูลจากการทดลองสนับสนุน',
            ),
            const SizedBox(height: 12),
            LearningTopicCard(
              title: 'โครงการวิจัย',
              description:
                  'เรียนรู้โครงสร้างและวิธีการเขียนรายงานการวิจัยฉบับสมบูรณ์',
              details:
                  'คำแนะนำสำหรับโครงการวิจัย:\n\n1. การทบทวนวรรณกรรม (Literature Review): ศึกษาค้นคว้างานวิจัยที่เกี่ยวข้องเพื่อหาช่องว่างขององค์ความรู้\n\n2. ระเบียบวิธีวิจัย (Methodology): อธิบายขั้นตอนการเก็บและวิเคราะห์ข้อมูลอย่างละเอียด\n\n3. การอภิปรายผล: เปรียบเทียบผลการวิจัยของคุณกับงานวิจัยอื่นๆ ที่ผ่านมา และเสนอแนะแนวทางสำหรับงานวิจัยในอนาคต\n\n4. การอ้างอิง: จัดการรายการอ้างอิงตามรูปแบบที่เป็นมาตรฐาน เช่น APA, IEEE',
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget ที่รวมข้อมูลและการแสดงผลของแต่ละหัวข้อไว้ในที่เดียว
class LearningTopicCard extends StatelessWidget {
  final String title;
  final String description;
  final String details;

  const LearningTopicCard({
    super.key,
    required this.title,
    required this.description,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LearningDetailScreen(title: title, details: details),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// หน้าจอสำหรับแสดงรายละเอียดของหัวข้อที่เลือก
class LearningDetailScreen extends StatelessWidget {
  final String title;
  final String details;

  const LearningDetailScreen({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            details,
            style: const TextStyle(
              fontSize: 16.0,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

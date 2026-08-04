import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProjectTemplates {
  // =========================================================================
  // TEMPLATES FOR "เอกสาร" (DOCUMENTS) TAB
  // =========================================================================
  static final Map<String, List<Map<String, dynamic>>> documentTemplates = {
    'NSC': [
      {'title': 'บทที่ 1: บทนำ (Introduction)', 'isChapter': true},
      {'title': 'ที่มาและความสำคัญของปัญหา'},
      {'title': 'วัตถุประสงค์ของโครงงาน'},
      {'title': 'ขอบเขตของโครงงาน'},
      {'title': 'ประโยชน์ที่คาดว่าจะได้รับ'},
      {'title': 'บทที่ 2: เอกสารและทฤษฎีที่เกี่ยวข้อง (Literature Review)', 'isChapter': true},
      {'title': 'ศึกษาหลักการทำงานของซอฟต์แวร์หรือเทคโนโลยีที่ใช้'},
      {'title': 'ศึกษาเครื่องมือและภาษาโปรแกรมที่เกี่ยวข้อง'},
      {'title': 'งานวิจัยหรือระบบตัวอย่างที่เกี่ยวข้อง'},
      {'title': 'บทที่ 3: วิธีการดำเนินงาน (Methodology)', 'isChapter': true},
      {'title': 'การวิเคราะห์และออกแบบระบบ (System Analysis & Design)'},
      {'title': 'เอกสารโครงร่างระบบ (System Architecture / Flowchart / ER Diagram)'},
      {'title': 'การออกแบบหน้าจอผู้ใช้ (UI/UX Design)'},
      {'title': 'เครื่องมือและสภาพแวดล้อมในการพัฒนา (Tools & Environment)'},
      {'title': 'บทที่ 4: ผลการดำเนินงาน (Results)', 'isChapter': true},
      {'title': 'ผลการพัฒนาระบบตามฟังก์ชันที่กำหนด'},
      {'title': 'เอกสารทดสอบระบบ (Test Cases & Results)'},
      {'title': 'บันทึกการแก้ไขข้อผิดพลาด (Bug Tracking Report)'},
      {'title': 'บทที่ 5: สรุปผลและข้อเสนอแนะ (Conclusion & Discussion)', 'isChapter': true},
      {'title': 'สรุปผลการดำเนินงานเทียบกับวัตถุประสงค์'},
      {'title': 'ปัญหา อุปสรรค และแนวทางแก้ไข'},
      {'title': 'ข้อเสนอแนะและแนวทางในการพัฒนาต่อในอนาคต'},
      {'title': 'คู่มือการใช้งานสำหรับผู้ดูแลระบบ (Admin Manual)'},
      {'title': 'คู่มือการใช้งานสำหรับผู้ใช้งานทั่วไป (User Manual)'},
    ],
    'วิทยาศาสตร์': [
      {'title': 'บทที่ 1: บทนำ (Introduction)', 'isChapter': true},
      {'title': 'ที่มาและความสำคัญของปัญหา'},
      {'title': 'วัตถุประสงค์ของโครงงาน'},
      {'title': 'สมมติฐานของการทดลอง'},
      {'title': 'ขอบเขตของการศึกษา'},
      {'title': 'ประโยชน์ที่คาดว่าจะได้รับ'},
      {'title': 'บทที่ 2: เอกสารและทฤษฎีที่เกี่ยวข้อง (Literature Review)', 'isChapter': true},
      {'title': 'ศึกษาทฤษฎีและหลักการทางวิทยาศาสตร์ที่เกี่ยวข้อง'},
      {'title': 'ทบทวนวรรณกรรมและงานวิจัยที่เคยศึกษามาก่อน'},
      {'title': 'บทที่ 3: อุปกรณ์และวิธีการดำเนินการ (Methodology)', 'isChapter': true},
      {'title': 'กำหนดตัวแปร (ตัวแปรต้น, ตัวแปรตาม, ตัวแปรควบคุม)'},
      {'title': 'รายการวัสดุ อุปกรณ์ และสารเคมีที่ใช้'},
      {'title': 'ขั้นตอนและวิธีการทดลอง (Experimental Procedure)'},
      {'title': 'บทที่ 4: ผลการทดลอง (Results)', 'isChapter': true},
      {'title': 'บันทึกผลการทดลองดิบ (Raw Data Logbook / ตารางบันทึกผล)'},
      {'title': 'การวิเคราะห์ข้อมูลทางสถิติหรือกราฟแสดงผลการทดลอง'},
      {'title': 'บทที่ 5: สรุปผล อภิปรายผล และข้อเสนอแนะ (Conclusion & Discussion)', 'isChapter': true},
      {'title': 'สรุปผลการทดลองและตรวจสอบเทียบกับสมมติฐาน'},
      {'title': 'อภิปรายผลการทดลองพร้อมเหตุผลทางวิทยาศาสตร์'},
      {'title': 'ข้อเสนอแนะสำหรับการศึกษาหรือทดลองครั้งต่อไป'},
      {'title': 'โปสเตอร์หรือบอร์ดนิทรรศการสำหรับจัดแสดงผลงาน (Exhibition Poster)'},
    ],
    'สังคม': [
      {'title': 'บทที่ 1: บทนำ (Introduction)', 'isChapter': true},
      {'title': 'ความเป็นมาและความสำคัญของปัญหาในชุมชน'},
      {'title': 'วัตถุประสงค์ของโครงการ'},
      {'title': 'เป้าหมายและกลุ่มเป้าหมายของโครงการ'},
      {'title': 'ประโยชน์ที่คาดว่าจะได้รับ'},
      {'title': 'บทที่ 2: แนวคิด ทฤษฎี และงานที่เกี่ยวข้อง (Literature Review)', 'isChapter': true},
      {'title': 'การศึกษาข้อมูลพื้นฐานของพื้นที่/ชุมชน'},
      {'title': 'แนวคิดและทฤษฎีเกี่ยวกับการพัฒนาสังคมหรือการแก้ปัญหา'},
      {'title': 'เอกสารวิเคราะห์สาเหตุและผลกระทบของปัญหา (Problem Tree Analysis)'},
      {'title': 'บทที่ 3: วิธีการดำเนินงาน (Methodology)', 'isChapter': true},
      {'title': 'การสำรวจพื้นที่และความต้องการของกลุ่มเป้าหมาย'},
      {'title': 'แผนงานปฏิบัติการ (Action Plan) และคำนวณงบประมาณ'},
      {'title': 'ขั้นตอนการจัดกิจกรรมหรือการแก้ไขปัญหาในพื้นที่จริง'},
      {'title': 'หนังสือขอความอนุเคราะห์ (ถ้ามี)'},
      {'title': 'บทที่ 4: ผลการดำเนินงาน (Results)', 'isChapter': true},
      {'title': 'ผลลัพธ์จากการจัดกิจกรรมตามแผนงาน'},
      {'title': 'ข้อมูลเชิงปริมาณและเชิงคุณภาพจากการดำเนินโครงการ'},
      {'title': 'ภาพถ่ายหลักฐานการดำเนินกิจกรรม'},
      {'title': 'บทที่ 5: สรุปผล การประเมินผล และข้อเสนอแนะ (Conclusion & Evaluation)', 'isChapter': true},
      {'title': 'ผลการประเมินความพึงพอใจของกลุ่มเป้าหมาย/ผู้เข้าร่วม'},
      {'title': 'สรุปผลการดำเนินโครงการเทียบกับวัตถุประสงค์'},
      {'title': 'ปัญหา อุปสรรค และข้อเสนอแนะเพื่อการต่อยอดโครงการในชุมชน'},
    ],
    'ทั่วไป': [
      {'title': 'บทที่ 1: บทนำ (Introduction)', 'isChapter': true},
      {'title': 'ที่มาและความสำคัญของปัญหา'},
      {'title': 'วัตถุประสงค์ของโครงงาน'},
      {'title': 'ขอบเขตของโครงงาน'},
      {'title': 'ประโยชน์ที่คาดว่าจะได้รับ'},
      {'title': 'บทที่ 2: เอกสารและทฤษฎีที่เกี่ยวข้อง (Literature Review)', 'isChapter': true},
      {'title': 'ศึกษาข้อมูล เอกสาร หรือแนวทางที่เกี่ยวข้องกับโครงงาน'},
      {'title': 'ศึกษาทฤษฎีหรือหลักการที่นำมาประยุกต์ใช้'},
      {'title': 'บทที่ 3: วิธีการดำเนินงาน (Methodology)', 'isChapter': true},
      {'title': 'แผนผังการแบ่งหน้าที่ความรับผิดชอบของสมาชิกในทีม (RACI Matrix / Team Structure)'},
      {'title': 'แผนผังกำหนดการทำงาน (Timeline / Project Schedule) และงบประมาณ'},
      {'title': 'ขั้นตอนและวิธีการดำเนินงาน / การสร้างชิ้นงาน'},
      {'title': 'บทที่ 4: ผลการดำเนินงาน (Results)', 'isChapter': true},
      {'title': 'บันทึกรายงานความคืบหน้าประจำสัปดาห์ (Weekly Progress Report)'},
      {'title': 'ผลการดำเนินงานหรือชิ้นงานตามที่ได้ออกแบบไว้'},
      {'title': 'เอกสารบันทึกปัญหา อุปสรรค และแนวทางแก้ไขระหว่างดำเนินงาน'},
      {'title': 'บทที่ 5: สรุปผลและข้อเสนอแนะ (Conclusion & Discussion)', 'isChapter': true},
      {'title': 'สรุปผลการดำเนินงานเทียบกับวัตถุประสงค์'},
      {'title': 'ปัญหา อุปสรรค และข้อเสนอแนะสำหรับการพัฒนาต่อยอด'},
      {'title': 'สื่อสำหรับนำเสนอผลงาน (Presentation Deck / Video Presentation)'},
    ],
  };

  // =========================================================================
  // TEMPLATES FOR "สิ่งที่ต้องทำ" (TO-DO) TAB
  // =========================================================================
  static final Map<String, List<Map<String, dynamic>>> todoTemplates = {
    'NSC': [
        {'title': 'ระยะเตรียมและเสนอโครงการ', 'isChapter': true},
        {'title': 'ศึกษาและกำหนดหัวข้อโครงงานคอมพิวเตอร์หรือนวัตกรรมซอฟต์แวร์'},
        {'title': 'เขียนข้อเสนอโครงการ (Proposal) ระบุวัตถุประสงค์และขอบเขต'},
        {'title': 'จัดทำโครงร่างระบบ (System Architecture) และออกแบบ UI/UX เบื้องต้น'},
        {'title': 'ระยะพัฒนาและทดสอบระบบ', 'isChapter': true},
        {'title': 'พัฒนาระบบส่วนหน้า (Frontend) และส่วนหลัง (Backend)'},
        {'title': 'เชื่อมต่อฐานข้อมูลและระบบความปลอดภัย'},
        {'title': 'ทดสอบการทำงานของระบบ (Testing) และแก้ไขข้อผิดพลาด (Bugs)'},
        {'title': 'ระยะส่งมอบและนำเสนอ', 'isChapter': true},
        {'title': 'จัดทำคู่มือการใช้งานระบบสำหรับผู้ใช้'},
        {'title': 'บันทึกวิดีโอสาธิตการทำงานของโปรแกรม'},
        {'title': 'จัดทำเล่มรายงานฉบับสมบูรณ์และเตรียมสไลด์สำหรับนำเสนอ'},
    ],
    'วิทยาศาสตร์': [
        {'title': 'ระยะวางแผนและการศึกษาค้นคว้า', 'isChapter': true},
        {'title': 'สำรวจปัญหา ตั้งคำถาม และกำหนดสมมติฐานการทดลอง'},
        {'title': 'ศึกษาค้นคว้าทฤษฎี เอกสาร และงานวิจัยที่เกี่ยวข้อง'},
        {'title': 'ออกแบบวิธีการทดลองและกำหนดตัวแปร (ต้น, ตาม, ควบคุม)'},
        {'title': 'ระยะดำเนินการทดลอง', 'isChapter': true},
        {'title': 'จัดเตรียมวัสดุ อุปกรณ์ และสารเคมี (ถ้ามี)'},
        {'title': 'ดำเนินการทดลองตามขั้นตอนและบันทึกผลข้อมูลอย่างเป็นระบบ'},
        {'title': 'วิเคราะห์และประมวลผลข้อมูลทางสถิติหรือกราฟเปรียบเทียบ'},
        {'title': 'ระยะสรุปผลและการเผยแพร่', 'isChapter': true},
        {'title': 'สรุปผลการทดลองและตรวจสอบเทียบกับสมมติฐาน'},
        {'title': 'จัดทำรายงานโครงงานวิทยาศาสตร์ตามรูปแบบมาตรฐาน'},
        {'title': 'จัดทำบอร์ดนิทรรศการและเตรียมตอบคำถามกรรมการ'},
    ],
    'สังคม': [
        {'title': 'ระยะสำรวจและคัดเลือกปัญหา', 'isChapter': true},
        {'title': 'สำรวจพื้นที่หรือกลุ่มเป้าหมายเพื่อหาปัญหาความเดือดร้อนในชุมชน'},
        {'title': 'วิเคราะห์สาเหตุและผลกระทบของปัญหาที่เลือก'},
        {'title': 'กำหนดกลุ่มเป้าหมายและวัตถุประสงค์ในการแก้ปัญหา'},
        {'title': 'ระยะวางแผนและดำเนินโครงการ', 'isChapter': true},
        {'title': 'ออกแบบกิจกรรมหรือโครงการแก้ไขปัญหา (เช่น การอบรม รณรงค์ หรือสร้างสิ่งประดิษฐ์เพื่อสังคม)'},
        {'title': 'จัดทำแผนปฏิบัติงาน งบประมาณ และแบ่งหน้าที่ความรับผิดชอบในทีม'},
        {'title': 'ดำเนินกิจกรรมตามแผนงานที่กำหนดไว้ในพื้นที่จริง'},
        {'title': 'ระยะประเมินผลและการรายงาน', 'isChapter': true},
        {'title': 'ติดตามผลและประเมินความพึงพอใจของกลุ่มเป้าหมาย'},
        {'title': 'สรุปผลการดำเนินโครงการและข้อเสนอแนะเพื่อพัฒนาต่อ'},
        {'title': 'จัดทำรายงานสรุปโครงการและสื่อวิดีโอนำเสนอผลงาน'},
    ],
    'ทั่วไป': [
        {'title': 'ระยะเตรียมการและวางแผนโครงการ', 'isChapter': true},
        {'title': 'ระบุและกำหนดหัวข้อหรือปัญหาที่ต้องการทำโครงงาน'},
        {'title': 'ศึกษาข้อมูล เอกสาร หรือแนวทางที่เกี่ยวข้องกับโครงงาน'},
        {'title': 'เขียนเค้าโครงโครงงาน (Project Proposal) ระบุวัตถุประสงค์ และประโยชน์ที่คาดว่าจะได้รับ'},
        {'title': 'กำหนดขอบเขตการดำเนินงาน แผนปฏิบัติงาน (Timeline) และงบประมาณ'},
        {'title': 'แบ่งหน้าที่ความรับผิดชอบให้กับสมาชิกภายในทีม'},
        {'title': 'ระยะดำเนินงานและปฏิบัติจริง', 'isChapter': true},
        {'title': 'จัดเตรียมเครื่องมือ วัสดุอุปกรณ์ หรือทรัพยากรที่จำเป็น'},
        {'title': 'ดำเนินการสร้าง ผลิต ชิ้นงาน หรือจัดกิจกรรมตามแผนงานที่วางไว้'},
        {'title': 'ตรวจสอบความคืบหน้าและประเมินผลการทำงานเป็นระยะ'},
        {'title': 'แก้ไขปรับปรุงข้อผิดพลาดหรืออุปสรรคที่พบระหว่างการทำงาน'},
        {'title': 'ระยะสรุปผลและการส่งมอบ', 'isChapter': true},
        {'title': 'สรุปผลการดำเนินงานและประเมินความสำเร็จเทียบกับวัตถุประสงค์'},
        {'title': 'จัดทำเล่มรายงานโครงงานฉบับสมบูรณ์'},
        {'title': 'จัดเตรียมสื่อนำเสนอ (Presentation) และซ้อมการนำเสนอผลงาน'},
    ]
  };

  /// Creates the initial set of tasks for a new project from templates.
  static Future<void> createTasksFromTemplate(
    String projectId,
    String projectType,
  ) async {
    debugPrint(
      "--- [TEMPLATE] Creating tasks for project type: $projectType ---",
    );

    final List<Map<String, dynamic>> tasksToCreate = [];
    int globalOrder = 0;

    // 1. Add tasks from the specific document template (e.g., 'NSC').
    if (documentTemplates.containsKey(projectType)) {
      final docTemplate = documentTemplates[projectType]!;
      tasksToCreate.addAll(
        docTemplate.map((task) {
          final taskWithOrder = {
            ...task,
            'isChapter': task['isChapter'] ?? false,
            'isTemplate': true,
            'order': globalOrder,
          };
          globalOrder++;
          return taskWithOrder;
        }),
      );
      debugPrint(
        "--- [TEMPLATE] Added ${docTemplate.length} tasks from '$projectType' document template. ---",
      );
    }

    // 2. Add tasks from the corresponding to-do template.
    final todoTemplate = todoTemplates[projectType] ?? todoTemplates['ทั่วไป']!;
    tasksToCreate.addAll(
      todoTemplate.map((task) {
        final taskWithOrder = {
          ...task,
          'isChapter': task['isChapter'] ?? false,
          'isTemplate': false,
          'isGeneralTemplate': true,
          'order': globalOrder,
        };
        globalOrder++;
        return taskWithOrder;
      }),
    );
    debugPrint(
      "--- [TEMPLATE] Added ${todoTemplate.length} tasks from the '$projectType' to-do template. ---",
    );


    if (tasksToCreate.isEmpty) {
      debugPrint("--- [TEMPLATE-ERROR] No tasks to create. Returning. ---");
      return;
    }

    // 3. Batch write all tasks to Firestore.
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final tasksCollection =
        firestore.collection('Events').doc(projectId).collection('tasks');

    for (final taskData in tasksToCreate) {
      final taskRef = tasksCollection.doc();
      batch.set(taskRef, {
        ...taskData,
        'dueDate': null,
        'isDone': false,
        'createdAt': FieldValue.serverTimestamp(),
        'assignedTo': null,
      });
    }

    try {
      await batch.commit();
      debugPrint("--- [TEMPLATE] Batch write of ${tasksToCreate.length} tasks completed successfully. ---");
    } catch (e) {
      debugPrint("--- [TEMPLATE-ERROR] Error during batch write: $e ---");
    }
  }
}

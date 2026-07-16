import 'package:flutter/material.dart';
import 'login_screen.dart';
// Note: หากต้องการแสดงภาพ SVG อย่าลืมลงแพ็กเกจ flutter_svg ใน pubspec.yaml
// แล้ว import 'package:flutter_svg/flutter_svg.dart'; ตรงนี้นะครับ

// สร้าง Model Class เพื่อความปลอดภัยของข้อมูล (Type Safety)
class OnboardingItem {
  final String title;
  final String subtitle;
  final String image;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // ย้ายข้อมูลออกมาเป็นค่าคงที่ (const) และใช้ Model ที่สร้างขึ้น
  static const List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      title: "จุดประกายไอเดียโครงงานของคุณ",
      subtitle:
          "หมดปัญหาคิดหัวข้อไม่ออก! ค้นหาแรงบันดาลใจและคลังความรู้ที่เหมาะกับความสนใจของคุณ ทั้งสายวิทย์ เทคโนโลยี หรือสิ่งประดิษฐ์",
      image: "assets/images/onboard_ideation.svg",
    ),
    OnboardingItem(
      title: "จัดการทุกขั้นตอนให้เป็นเรื่องง่าย",
      subtitle:
          "วางแผนการทำงาน แบ่งเป้าหมายเป็นสัดส่วน และติดตามความคืบหน้าของโครงงานได้แบบเรียลไทม์ ไม่พลาดทุกกำหนดส่ง",
      image: "assets/images/onboard_planning.svg",
    ),
    OnboardingItem(
      title: "ผู้ช่วยแก้ปัญหาข้างกายคุณ",
      subtitle:
          "ติดขัดตรงไหนให้เราช่วย แนะนำตั้งแต่อุปกรณ์ที่ต้องใช้ ไปจนถึงช่วยวิเคราะห์และไขข้อสงสัยระหว่างการทดลอง",
      image: "assets/images/onboard_assistant.svg",
    ),
    OnboardingItem(
      title: "พร้อมนำเสนอความสำเร็จ",
      subtitle:
          "รวบรวมข้อมูลทั้งหมดเพื่อจัดทำรายงานและสรุปผลงานให้พร้อมสำหรับการนำเสนอ เริ่มต้นสร้างโครงงานชิ้นเอกของคุณได้เลย!",
      image: "assets/images/onboard_showcase.svg",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ฟังก์ชันทางลัดเพื่อไปยังหน้า Login
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ปุ่มข้าม (จะแสดงเฉพาะหน้า 1-3 พอถึงหน้าสุดท้ายจะซ่อนไปเพื่อให้โฟกัสกับปุ่มเริ่มใช้งาน)
            Align(
              alignment: Alignment.topRight,
              child: _currentPage < _onboardingData.length - 1
                  ? TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        "ข้าม",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 48,
                    ), // คงพื้นที่ไว้ไม่ให้ Layout เลื่อนขยับ
            ),

            // 2. ส่วนเนื้อหา PageView ดึงข้อมูลจาก _onboardingData มาแสดง
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardContent(
                    title: _onboardingData[index].title,
                    subtitle: _onboardingData[index].subtitle,
                    imagePath: _onboardingData[index].image,
                  );
                },
              ),
            ),

            // 3. จุดไข่ปลาบอกตำแหน่งหน้า (Page Indicator) แบบแอนิเมชันยืดหดได้
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 8,
                  width: _currentPage == index
                      ? 24
                      : 8, // หน้าที่เลือกอยู่จะยาวกว่าปกติ
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context)
                              .primaryColor // สีหลักของแอปคุณ
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. ปุ่มกดด้านล่าง (เช็กสถานะเพื่อเปลี่ยนคำและเปลี่ยน Action)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      // ถ้าอยู่หน้าสุดท้าย ให้ไปหน้า Login
                      _navigateToLogin();
                    } else {
                      // ถ้าอยู่หน้าแรกๆ ให้เลื่อนไปหน้าถัดไป
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? "เริ่มต้นใช้งาน"
                        : "ถัดไป",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Component แยกสำหรับจัดหน้า Layout (รูป SVG + ข้อความ) ให้สแกนโค้ดง่ายขึ้น
class OnboardContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // พื้นที่สำหรับใส่ภาพ SVG (สัดส่วนความสูง Flex 3 ส่วน)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // เปลี่ยนพื้นหลังเป็นสีฟ้าอ่อน
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                // เมื่อคุณติดตั้งแพ็กเกจ flutter_svg เรียบร้อยแล้ว
                // ให้ลบโค้ดตระกูล Column ด้านล่างนี้ออก แล้วเปิดใช้งานบรรทัด SvgPicture แทนได้เลยครับ
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.blue.shade200,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "พื้นที่ใส่ SVG:\n$imagePath",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueGrey.shade300,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // child: SvgPicture.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),

          // ส่วนแสดงผลข้อความหลักและข้อความรอง (สัดส่วนความสูง Flex 2 ส่วน)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold, // สีของ Title ยังคงเดิมเพื่อความชัดเจน
                    color: Color(0xFF1A2533), // หรือใช้ Colors.black87
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15, // สีของ Subtitle ยังคงเดิมเพื่อความอ่านง่าย
                    color: Colors.blueGrey.shade700,
                    height: 1.5, // ระยะห่างระหว่างบรรทัดให้อ่านง่าย
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

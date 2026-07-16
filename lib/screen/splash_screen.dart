import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _zoomInAnimation;
  late Animation<double> _textFadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3500,
      ), // 2.0s สำหรับ fade-in และ pop, 1.5s สำหรับ zoom-out
    );

    // Fade-in เริ่มต้น
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // "ระเบิด" ขยายเล็กน้อย
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.elasticOut),
      ),
    );

    // ซูมขยายใหญ่ในช่วงท้าย (1.5 วินาทีสุดท้าย)
    _zoomInAnimation = Tween<double>(begin: 1.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.57,
          1.0,
          curve: Curves.easeIn,
        ), // 3500 * 0.57 ~= 2000ms
      ),
    );

    // ข้อความจางหายไปพร้อมกับการซูม
    _textFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.57, 0.8, curve: Curves.easeOut),
      ),
    );

    // เมื่ออนิเมชันเล่นจบ ให้เปลี่ยนหน้า
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 700),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                // 3. ซูมขยายใหญ่
                scale: _zoomInAnimation,
                child: ScaleTransition(
                  // 2. ระเบิดออก
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 70,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                // 4. ข้อความจางหายไป
                opacity: _textFadeOutAnimation,
                child: const Text(
                  "Project in My Pocket",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

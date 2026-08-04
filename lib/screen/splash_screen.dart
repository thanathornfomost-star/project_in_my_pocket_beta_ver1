import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_in_my_pocket_beta_ver1/screen/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _settleController;
  late AnimationController _blastController;

  late Animation<double> _logoFadeIn;
  late Animation<double> _logoPulse;
  late Animation<double> _logoShrink;
  late Animation<double> _logoExpand;
  late Animation<double> _textFadeIn;
  late Animation<double> _fadeOut;

  bool _isSettled = false;

  @override
  void initState() {
    super.initState();

    // Controller for the initial settlement animation (2s)
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controller for the blast/reveal animation (800ms)
    _blastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Phase 1: Logo Settlement Animations
    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _settleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _textFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _settleController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );
    _logoPulse = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _settleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Phase 2 & 3: Gathering and Expansion Animations
    _logoShrink = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _blastController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    _logoExpand = Tween<double>(begin: 1.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _blastController,
        curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _blastController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _settleController.forward();
    _settleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSettled = true);
        // Simulate background loading
        Timer(const Duration(milliseconds: 500), () {
          _blastController.forward();
        });
      }
    });

    _blastController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const AuthGate(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _settleController.dispose();
    _blastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: _isSettled
            ? ScaleTransition(
                scale: _logoExpand,
                child: FadeTransition(
                  opacity: _fadeOut,
                  child: ScaleTransition(
                    scale: _logoShrink,
                    child: _buildLogo(),
                  ),
                ),
              )
            : FadeTransition(
                opacity: _logoFadeIn,
                child: ScaleTransition(
                  scale: _logoPulse,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _textFadeIn,
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
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: const Icon(
        Icons.school_outlined,
        size: 70,
        color: Colors.blue,
      ),
    );
  }
}

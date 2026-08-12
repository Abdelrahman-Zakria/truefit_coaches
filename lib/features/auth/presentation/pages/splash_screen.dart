import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fillController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeInOut),
    );

    _fillController.forward();

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulse rings
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: (1.0 - (_pulseController.value)).clamp(0.0, 0.6),
                          child: Container(
                            width: 208 * _pulseAnimation.value,
                            height: 208 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.1)),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.15)),
                      ),
                    ),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRed.withValues(alpha:0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Profile Pic.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                             return Container(
                               color: Colors.white10,
                               child: const Icon(Icons.fitness_center, color: AppTheme.primaryRed, size: 40),
                             );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'PREMIUM FITNESS',
                  style: TextStyle(
                    color: Color(0xFF6B7280), // gray-500
                    fontSize: 12,
                    letterSpacing: 3.6, // 0.3em
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Loading bar
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 144,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedBuilder(
                  animation: _fillAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 144 * _fillAnimation.value,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

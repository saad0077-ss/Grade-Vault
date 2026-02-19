import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/services/hive_services.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _contentController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _contentController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _particleController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat();
    _glowController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _ringScale = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringController, curve: Curves.elasticOut));
    _ringOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.elasticOut));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _titleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _contentController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeIn)));
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeIn)));

    _glowPulse = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ringController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final hasType = HiveServices.hasStudentType;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) =>
        hasType ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim, child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _contentController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          // Glow blob center
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, __) => Center(
              child: Container(
                width: 300 * _glowPulse.value,
                height: 300 * _glowPulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGlow,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Rings
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) => Opacity(
                opacity: _ringOpacity.value,
                child: Transform.scale(
                  scale: _ringScale.value,
                  child: CustomPaint(
                    painter: _RingsPainter(),
                    size: const Size(280, 280),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGlow,
                              blurRadius: 32,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: AppColors.background, size: 44),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title
                  SlideTransition(
                    position: _titleSlide,
                    child: Opacity(
                      opacity: _titleOpacity.value,
                      child: Text('GradeVault',
                          style: AppTextStyles.display.copyWith(
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppColors.accent, AppColors.teal],
                              ).createShader(
                                  const Rect.fromLTWH(0, 0, 240, 60)),
                          )),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      'Track every mark. Own your future.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom loader
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (_, __) => Opacity(
                opacity: _subtitleOpacity.value,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        minHeight: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Preparing your vault...',
                        style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radii = [110.0, 85.0, 60.0];
    final opacities = [0.08, 0.12, 0.18];

    for (int i = 0; i < radii.length; i++) {
      canvas.drawCircle(
        center, radii[i],
        Paint()
          ..color = AppColors.accent.withOpacity(opacities[i])
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _particles = List.generate(30, (i) => [
    _rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble() * 3 + 1,
    _rng.nextDouble(), _rng.nextDouble() * 0.3 + 0.05,
  ]);

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x = p[0] * size.width;
      final speed = p[3];
      final y = (p[1] * size.height - progress * speed * 80) % size.height;
      final radius = p[2];
      final opacity = p[4];
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColors.accent.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
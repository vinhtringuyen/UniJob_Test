import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Bảng màu chủ đạo của UniJob
  static const Color navy = Color(0xFF071426);
  static const Color blue = Color(0xFF2589D8);
  static const Color mint = Color(0xFF72E0D2);

  late final AnimationController _backgroundController;
  late final AnimationController _logoController;
  late final AnimationController _progressController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // Chuyển động ánh sáng nền
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Hiệu ứng xuất hiện logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _contentOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Thanh tiến trình trong thời gian khởi động
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _logoController.forward();

    // GIỮ NGUYÊN THỜI GIAN VÀ LIÊN KẾT ĐIỀU HƯỚNG
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. NỀN GRADIENT CAO CẤP
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF102F4A),
                  Color(0xFF091B30),
                  Color(0xFF050D19),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
            ),
          ),

          // 2. ÁNH SÁNG NỀN CHUYỂN ĐỘNG
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final value = _backgroundController.value;

              return Stack(
                children: [
                  Positioned(
                    top: 100 + value * 50,
                    left: -100 + value * 25,
                    child: _GlowOrb(
                      size: 250,
                      color: blue.withOpacity(0.20),
                    ),
                  ),
                  Positioned(
                    right: -110 - value * 30,
                    bottom: 100 + value * 35,
                    child: _GlowOrb(
                      size: 280,
                      color: mint.withOpacity(0.14),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.sizeOf(context).height * 0.32,
                    right: 35 + value * 15,
                    child: _GlowOrb(
                      size: 70,
                      color: blue.withOpacity(0.08),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. HỌA TIẾT LƯỚI CÔNG NGHỆ
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TechGridPainter(),
              ),
            ),
          ),

          // 4. NỘI DUNG CHÍNH
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 650;

                return Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo có hiệu ứng phóng to và phát sáng
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoController,
                        _backgroundController,
                      ]),
                      builder: (context, child) {
                        final pulse =
                            1.0 + _backgroundController.value * 0.025;

                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value * pulse,
                            child: Container(
                              width: compact ? 124 : 146,
                              height: compact ? 124 : 146,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(38),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF9BF4E9),
                                    Color(0xFF36A9E5),
                                    Color(0xFF176BBA),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: mint.withOpacity(
                                      0.15 +
                                          _backgroundController.value * 0.12,
                                    ),
                                    blurRadius:
                                        30 + _backgroundController.value * 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10263A),
                                  borderRadius: BorderRadius.circular(34),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(29),
                                  child: Image.asset(
                                    'assets/images/logo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [mint, blue],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.bolt_rounded,
                                          color: navy,
                                          size: 65,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: compact ? 28 : 35),

                    // TÊN THƯƠNG HIỆU
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            const Text(
                              'UniJob',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                                height: 1.15,
                              ),
                            ),

                            const SizedBox(height: 13),

                            // Đường nét chuyển sắc
                            Container(
                              width: 48,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [mint, blue],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: mint.withOpacity(0.35),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                'Kết nối nhân lực - Kiến tạo cơ hội',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFD5E4F0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'CƠ HỘI THEO CÁCH CỦA BẠN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: mint.withOpacity(0.9),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // THANH TIẾN TRÌNH
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 55),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  height: 4,
                                  child: LinearProgressIndicator(
                                    value: _progressController.value,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.10),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      mint,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ĐANG KHỞI TẠO TRẢI NGHIỆM',
                                style: TextStyle(
                                  color: Color(0xFF91AFC7),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: compact ? 30 : 42),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HIỆU ỨNG ÁNH SÁNG
// ======================================================

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.45,
              spreadRadius: size * 0.10,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HỌA TIẾT LƯỚI NỀN
// ======================================================

class _TechGridPainter extends CustomPainter {
  const _TechGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D8F2).withOpacity(0.035)
      ..strokeWidth = 0.7;

    const spacing = 36.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
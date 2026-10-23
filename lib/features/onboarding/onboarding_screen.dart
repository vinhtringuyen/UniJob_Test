import 'dart:ui';
import 'package:flutter/material.dart';
import '../auth/role_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final AnimationController _glowController;
  late final AnimationController _floatController;

  static const Color mint = Color(0xFF72E0D2);
  static const Color blue = Color(0xFF2589D8);
  static const Color navy = Color(0xFF071426);

  final List<_Slide> _slides = const [
    _Slide(
      eyebrow: 'BẮT ĐẦU TỪ BẠN',
      title: 'Hồ sơ tốt.\nCơ hội xứng tầm.',
      description:
          'Xây dựng hồ sơ năng lực nổi bật, thể hiện kỹ năng và kinh nghiệm để mở ra những cơ hội phù hợp.',
      icon: Icons.person_search_rounded,
      tag: 'Hồ sơ cá nhân',
      step: '01',
    ),
    _Slide(
      eyebrow: 'LÀM CHỦ THỜI GIAN',
      title: 'Lịch học linh hoạt.\nViệc làm phù hợp.',
      description:
          'Chủ động cập nhật thời gian rảnh để UniJob tìm kiếm công việc phù hợp với lịch học của bạn.',
      icon: Icons.calendar_month_rounded,
      tag: 'Lịch trình thông minh',
      step: '02',
    ),
    _Slide(
      eyebrow: 'KẾT NỐI THÔNG MINH',
      title: 'Đúng người.\nĐúng cơ hội.',
      description:
          'Kết nối với doanh nghiệp phù hợp dựa trên kỹ năng, lịch trình và mong muốn của bạn.',
      icon: Icons.hub_rounded,
      tag: 'Kết nối UniJob',
      step: '03',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, animation, secondaryAnimation) =>
              const RoleScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _Background(),
          ),

          // Ánh sáng nền chuyển động nhẹ
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final value = _glowController.value;

                return Stack(
                  children: [
                    Positioned(
                      left: -100 + value * 35,
                      top: 100,
                      child: _Glow(
                        size: 220,
                        color: blue.withValues(alpha: 0.18),
                      ),
                    ),
                    Positioned(
                      right: -110 - value * 25,
                      bottom: 120,
                      child: _Glow(
                        size: 260,
                        color: mint.withValues(alpha: 0.13),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header thương hiệu
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [mint, blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: mint.withValues(alpha: 0.2),
                              blurRadius: 22,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: navy,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UniJob',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'YOUR CAREER STARTS HERE',
                            style: TextStyle(
                              color: Color(0xFF91AFC7),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_currentIndex < _slides.length - 1)
                        TextButton(
                          onPressed: _skip,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFD5E4F0),
                          ),
                          child: const Text(
                            'Bỏ qua',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Nội dung onboarding
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: index == _currentIndex ? 1 : 0.65,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                index == _currentIndex
                                    ? -4 * _floatController.value
                                    : 0,
                              ),
                              child: _SlideView(
                                slide: _slides[index],
                                compact: compact,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Điều hướng cuối màn hình
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    26,
                    8,
                    26,
                    compact ? 18 : 28,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              _slides.length,
                              _buildDot,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '0${_currentIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            ' / 03',
                            style: TextStyle(
                              color: Color(0xFF7189A0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Nút gradient
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [mint, Color(0xFF52BDEB), blue],
                            ),
                            borderRadius: BorderRadius.circular(19),
                            boxShadow: [
                              BoxShadow(
                                color: blue.withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _nextPage,
                              borderRadius: BorderRadius.circular(19),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Row(
                                  key: ValueKey(_currentIndex),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentIndex == _slides.length - 1
                                          ? 'Khám phá UniJob'
                                          : 'Tiếp tục',
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      _currentIndex == _slides.length - 1
                                          ? Icons.rocket_launch_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: navy,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 13,
                            color: Color(0xFF6F8CA3),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Bắt đầu hành trình nghề nghiệp của bạn',
                            style: TextStyle(
                              color: Color(0xFF8097AC),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final selected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 7),
      width: selected ? 30 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: selected ? mint : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: mint.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }
}

// ============================================================
// WIDGET NỘI DUNG TỪNG TRANG
// ============================================================

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.compact,
  });

  final _Slide slide;
  final bool compact;

  static const Color mint = Color(0xFF72E0D2);
  static const Color blue = Color(0xFF2589D8);

  @override
  Widget build(BuildContext context) {
    final artSize = compact ? 185.0 : 220.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 2 : 12,
                24,
                8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minh họa biểu tượng
                  SizedBox(
                    height: artSize + 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: artSize,
                          height: artSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                blue.withValues(alpha: 0.22),
                                mint.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        Container(
                          width: artSize * 0.76,
                          height: artSize * 0.76,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.14),
                                Colors.white.withValues(alpha: 0.035),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: blue.withValues(alpha: 0.12),
                                blurRadius: 35,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Positioned(
                                top: 17,
                                right: 18,
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: mint,
                                  size: 17,
                                ),
                              ),
                              const Positioned(
                                bottom: 20,
                                left: 20,
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFA6C9E4),
                                  size: 15,
                                ),
                              ),
                              Container(
                                width: artSize * 0.44,
                                height: artSize * 0.44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [mint, blue],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mint.withValues(alpha: 0.25),
                                      blurRadius: 30,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  slide.icon,
                                  color: const Color(0xFF071426),
                                  size: artSize * 0.22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Positioned(
                          top: 22,
                          right: 0,
                          child: _GlassBadge(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Smart match',
                          ),
                        ),
                        const Positioned(
                          bottom: 20,
                          left: 0,
                          child: _GlassBadge(
                            icon: Icons.check_circle_rounded,
                            label: 'Sẵn sàng',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nhãn giới thiệu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: mint.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: mint.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        Text(
                          slide.eyebrow,
                          style: const TextStyle(
                            color: mint,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 17),

                  // Tiêu đề chính
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 29 : 33,
                      height: 1.17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Mô tả
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Text(
                      slide.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB6C7D8),
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 21),

                  // Nhãn tính năng
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          slide.icon,
                          size: 15,
                          color: mint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slide.tag,
                          style: const TextStyle(
                            color: Color(0xFFD9E5EF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Container(
                          width: 1,
                          height: 14,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          slide.step,
                          style: const TextStyle(
                            color: Color(0xFF819AAF),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// WIDGET NHÃN KÍNH MỜ
// ============================================================

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF10263A).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFF72E0D2),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NỀN GRADIENT VÀ HỌA TIẾT CÔNG NGHỆ
// ============================================================

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D2940),
                Color(0xFF08182B),
                Color(0xFF050D1A),
              ],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
        CustomPaint(
          painter: _GridPainter(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.015),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
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
              spreadRadius: size * 0.12,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D8F2).withValues(alpha: 0.035)
      ..strokeWidth = 0.7;

    const spacing = 34.0;

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

// ============================================================
// DỮ LIỆU CÁC TRANG ONBOARDING
// ============================================================

class _Slide {
  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
    required this.step,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final String tag;
  final String step;
}
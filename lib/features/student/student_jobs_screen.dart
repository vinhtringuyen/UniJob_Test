import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/student_service.dart';

class StudentJobsScreen extends StatefulWidget {
  const StudentJobsScreen({super.key});

  @override
  State<StudentJobsScreen> createState() => _StudentJobsScreenState();
}

class _StudentJobsScreenState extends State<StudentJobsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF176B87);
  static const Color secondaryColor = Color(0xFF2589D8);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF172B4D);
  static const Color mutedColor = Color(0xFF718096);

  final StudentService _studentService = StudentService();

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final Set<String> _applyingJobIds = <String>{};

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  Future<void> _applyForJob({
    required String jobId,
    required String jobTitle,
    required String companyName,
  }) async {
    if (_applyingJobIds.contains(jobId)) return;

    setState(() {
      _applyingJobIds.add(jobId);
    });

    bool success = false;

    try {
      // Giữ nguyên nghiệp vụ ứng tuyển của StudentService.
      success = await _studentService.applyForJob(
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    setState(() {
      _applyingJobIds.remove(jobId);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? 'Ứng tuyển thành công! Doanh nghiệp sẽ sớm liên hệ với bạn.'
                      : 'Ứng tuyển chưa thành công. Vui lòng kiểm tra và hoàn thiện hồ sơ CV.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? const Color(0xFF18865D) : const Color(0xFFD64545),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 66,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khám phá việc làm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Tìm cơ hội phù hợp cùng UniJob',
              style: TextStyle(
                color: Color(0xFFD6EAF2),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            // Giữ nguyên truy vấn Firestore hiện tại.
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _JobsLoadingView();
              }

              if (snapshot.hasError) {
                return const _JobsErrorView();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const _JobsEmptyView();
              }

              final jobDocs = snapshot.data!.docs;

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    children: [
                      _buildWelcomeCard(jobDocs.length),
                      const SizedBox(height: 23),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Việc làm dành cho bạn',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2F8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${jobDocs.length} công việc',
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Khám phá công việc và chọn cơ hội phù hợp với bạn.',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...jobDocs.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final jobDoc = entry.value;
                        final job =
                            jobDoc.data() as Map<String, dynamic>;

                        final String jobId = jobDoc.id;
                        final String jobTitle =
                            job['title'] ?? 'Tiêu đề công việc';
                        final String companyName =
                            job['companyName'] ?? 'Tên doanh nghiệp';
                        final String location =
                            job['location'] ?? 'Trà Vinh';
                        final String salary =
                            job['salary'] ?? 'Thỏa thuận';

                        return _JobCard(
                          key: ValueKey(jobId),
                          jobTitle: jobTitle,
                          companyName: companyName,
                          location: location,
                          salary: salary,
                          index: index,
                          isApplying: _applyingJobIds.contains(jobId),
                          onApply: () => _applyForJob(
                            jobId: jobId,
                            jobTitle: jobTitle,
                            companyName: companyName,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(int jobCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF176B87),
            Color(0xFF2187A2),
            Color(0xFF2D9BAA),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -40,
            child: _DecorativeCircle(
              size: 125,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Positioned(
            right: 55,
            bottom: -55,
            child: _DecorativeCircle(
              size: 95,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.23),
                      ),
                    ),
                    child: const Icon(
                      Icons.work_history_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cơ hội tiếp theo đang chờ bạn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kết nối đúng người, mở lối đúng cơ hội!',
                          style: TextStyle(
                            color: Color(0xFFE0F2F7),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.explore_outlined,
                      color: Color(0xFFFFE6A7),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Hiện có $jobCount cơ hội đang được hiển thị.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String salary;
  final int index;
  final bool isApplying;
  final VoidCallback onApply;

  const _JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.index,
    required this.isApplying,
    required this.onApply,
  });

  static const Color primaryColor = Color(0xFF176B87);
  static const Color textColor = Color(0xFF172B4D);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 350 + (index.clamp(0, 5) * 80),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color(0xFFE7EDF4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173A56).withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE5F5FA),
                        Color(0xFFDCEAF8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEDF1F6),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: primaryColor,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Địa điểm',
                        style: TextStyle(
                          color: Color(0xFF8493A7),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          location,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF40546B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFE7EDF4),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFF18865D),
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Mức lương',
                        style: TextStyle(
                          color: Color(0xFF8493A7),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          salary,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF18865D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 49,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isApplying
                      ? null
                      : const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF176B87),
                            Color(0xFF2589D8),
                          ],
                        ),
                  color: isApplying ? const Color(0xFF9BB8C5) : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isApplying
                      ? []
                      : [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.17),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: isApplying ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isApplying
                        ? const Row(
                            key: ValueKey('applying'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'ĐANG ỨNG TUYỂN...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            key: ValueKey('apply'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size: 17,
                              ),
                              SizedBox(width: 9),
                              Text(
                                'ỨNG TUYỂN NGAY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                              ),
                            ],
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

class _JobsLoadingView extends StatelessWidget {
  const _JobsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              color: Color(0xFF176B87),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Đang tìm kiếm cơ hội cho bạn...',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobsEmptyView extends StatelessWidget {
  const _JobsEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F3F8),
                borderRadius: BorderRadius.circular(34),
              ),
              child: const Icon(
                Icons.work_off_outlined,
                size: 52,
                color: Color(0xFF176B87),
              ),
            ),
            const SizedBox(height: 23),
            const Text(
              'Chưa có tin tuyển dụng',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hiện chưa có công việc nào được đăng. Hãy quay lại sau để khám phá những cơ hội mới nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 13,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobsErrorView extends StatelessWidget {
  const _JobsErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFD64545),
                size: 43,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không thể tải việc làm',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Đã xảy ra lỗi khi tải danh sách việc làm. Vui lòng thử lại sau.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
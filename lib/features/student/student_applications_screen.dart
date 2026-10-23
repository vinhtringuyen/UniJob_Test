import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentApplicationsScreen extends StatelessWidget {
  const StudentApplicationsScreen({super.key});

  static const Color primaryColor = Color(0xFF176B87);
  static const Color secondaryColor = Color(0xFF2589D8);
  static const Color backgroundColor = Color(0xFFF4F8FC);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: _LoginRequiredView(),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 155,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 20,
                bottom: 18,
              ),
              title: const Text(
                'Đơn ứng tuyển',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF176B87),
                          Color(0xFF124C70),
                          Color(0xFF0A3152),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -45,
                    child: _DecorativeCircle(
                      size: 170,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  Positioned(
                    right: 75,
                    top: 45,
                    child: _DecorativeCircle(
                      size: 55,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 58,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theo dõi cơ hội của bạn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cập nhật hành trình tìm việc',
                              style: TextStyle(
                                color: Color(0xFFD7EAF4),
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
          ),

          StreamBuilder<QuerySnapshot>(
            // Giữ nguyên truy vấn: chỉ lấy đơn của sinh viên hiện tại.
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('studentUid', isEqualTo: currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingView(),
                );
              }

              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(),
                );
              }

              final appDocs = snapshot.data?.docs ?? [];

              if (appDocs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyApplicationsView(),
                );
              }

              final int total = appDocs.length;
              final int accepted = appDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'Pending';
                return status == 'Approved' || status == 'Accepted';
              }).length;
              final int rejected = appDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['status'] ?? 'Pending') == 'Rejected';
              }).length;
              final int pending = total - accepted - rejected;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        color: Color(0xFF172B4D),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.description_rounded,
                            label: 'Tổng đơn',
                            value: '$total',
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.hourglass_top_rounded,
                            label: 'Đang chờ',
                            value: '$pending',
                            color: const Color(0xFFE99A26),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.check_circle_rounded,
                            label: 'Đã nhận',
                            value: '$accepted',
                            color: const Color(0xFF239B72),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Lịch sử ứng tuyển',
                            style: TextStyle(
                              color: Color(0xFF172B4D),
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
                            '$total đơn',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ...appDocs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final appData =
                          entry.value.data() as Map<String, dynamic>;

                      final String jobTitle =
                          appData['jobTitle'] ?? 'Tiêu đề công việc';
                      final String companyName =
                          appData['companyName'] ?? 'Tên doanh nghiệp';
                      final String status =
                          appData['status'] ?? 'Pending';

                      return _ApplicationCard(
                        jobTitle: jobTitle,
                        companyName: companyName,
                        status: status,
                        index: index,
                      );
                    }),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Thẻ thống kê
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF153A5B).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Thẻ đơn ứng tuyển có hiệu ứng xuất hiện nhẹ
class _ApplicationCard extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String status;
  final int index;

  const _ApplicationCard({
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBackground;
    IconData statusIcon;
    String statusText;

    if (status == 'Approved' || status == 'Accepted') {
      statusColor = const Color(0xFF18865D);
      statusBackground = const Color(0xFFE5F7EE);
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Đã chấp nhận';
    } else if (status == 'Rejected') {
      statusColor = const Color(0xFFD64545);
      statusBackground = const Color(0xFFFFEEEE);
      statusIcon = Icons.cancel_rounded;
      statusText = 'Đã từ chối';
    } else {
      statusColor = const Color(0xFFB7791F);
      statusBackground = const Color(0xFFFFF4DB);
      statusIcon = Icons.schedule_rounded;
      statusText = 'Đang chờ duyệt';
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('$jobTitle-$companyName-$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index.clamp(0, 5) * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF153A5B).withValues(alpha: 0.045),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE5F5FA),
                        Color(0xFFD9EAF8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: Color(0xFF176B87),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF172B4D),
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 15,
                              color: Color(0xFF8493A7),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                companyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),
            const Divider(height: 1, color: Color(0xFFEDF1F6)),
            const SizedBox(height: 14),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Trạng thái hồ sơ',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

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
              strokeWidth: 3,
              color: Color(0xFF176B87),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Đang tải lịch sử ứng tuyển...',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyApplicationsView extends StatelessWidget {
  const _EmptyApplicationsView();

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
                Icons.assignment_outlined,
                size: 54,
                color: Color(0xFF176B87),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có đơn ứng tuyển',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Những công việc bạn ứng tuyển sẽ xuất hiện tại đây. Hãy bắt đầu tìm kiếm cơ hội phù hợp nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Color(0xFFD64545),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đã xảy ra lỗi khi tải lịch sử ứng tuyển. Vui lòng kiểm tra kết nối và thử lại sau.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F3F8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: Color(0xFF176B87),
                size: 46,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Bạn chưa đăng nhập',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Vui lòng đăng nhập để theo dõi lịch sử ứng tuyển của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
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
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
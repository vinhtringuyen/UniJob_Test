import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentInvitationsScreen extends StatelessWidget {
  // Giữ nguyên ID sinh viên dùng để lọc lời mời.
  final String currentStudentId;

  const StudentInvitationsScreen({
    super.key,
    required this.currentStudentId,
  });

  static const Color primaryColor = Color(0xFF136A84);
  static const Color secondaryColor = Color(0xFF2589D8);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF172B4D);
  static const Color mutedColor = Color(0xFF718096);

  // Giữ nguyên collection và trường cập nhật Firestore.
  Future<void> _updateStatus(
    BuildContext context,
    String docId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(docId)
          .update({
        'status': newStatus,
      });

      if (!context.mounted) return;

      final bool accepted = newStatus == 'accepted';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accepted
                ? 'Bạn đã chấp nhận lời mời phỏng vấn.'
                : 'Bạn đã từ chối lời mời phỏng vấn.',
          ),
          backgroundColor:
              accepted ? const Color(0xFF18865D) : const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Không thể cập nhật trạng thái. Vui lòng thử lại.',
          ),
          backgroundColor: const Color(0xFFD64545),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lời mời phỏng vấn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Cơ hội nghề nghiệp dành cho bạn',
              style: TextStyle(
                color: Color(0xFFD8EBF2),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Giữ nguyên truy vấn realtime, bộ lọc và thứ tự dữ liệu.
        stream: FirebaseFirestore.instance
            .collection('invitations')
            .where('studentId', isEqualTo: currentStudentId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return const _ErrorView();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _EmptyView();
          }

          final invitations = snapshot.data!.docs;

          final int total = invitations.length;
          final int accepted = invitations.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? 'pending') == 'accepted';
          }).length;
          final int rejected = invitations.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? 'pending') == 'rejected';
          }).length;
          final int pending = total - accepted - rejected;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
            children: [
              _buildHeader(total),
              const SizedBox(height: 20),

              const Text(
                'Tổng quan lời mời',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.mark_email_unread_rounded,
                      label: 'Tổng lời mời',
                      value: '$total',
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.schedule_rounded,
                      label: 'Chờ phản hồi',
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

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách lời mời',
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
                      '$total lời mời',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              ...invitations.asMap().entries.map((entry) {
                final int index = entry.key;
                final doc = entry.value;
                final data = doc.data() as Map<String, dynamic>;

                final String employerName =
                    data['employerName'] ?? 'Nhà tuyển dụng';
                final String jobTitle = data['jobTitle'] ?? 'Công việc';
                final String status = data['status'] ?? 'pending';

                return _InvitationCard(
                  employerName: employerName,
                  jobTitle: jobTitle,
                  status: status,
                  index: index,
                  onAccept: () => _updateStatus(
                    context,
                    doc.id,
                    'accepted',
                  ),
                  onReject: () => _updateStatus(
                    context,
                    doc.id,
                    'rejected',
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF136A84),
            Color(0xFF2187A2),
            Color(0xFF2D9BAA),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: _DecorativeCircle(
              size: 115,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Positioned(
            right: 55,
            bottom: -50,
            child: _DecorativeCircle(
              size: 85,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.video_call_rounded,
                      size: 29,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bạn đang được quan tâm!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Khám phá những cơ hội mới cùng UniJob.',
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
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.13),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFFFFE6A7),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        total == 0
                            ? 'Bạn chưa có lời mời phỏng vấn nào.'
                            : 'Bạn đang có $total lời mời phỏng vấn.',
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

class _InvitationCard extends StatelessWidget {
  final String employerName;
  final String jobTitle;
  final String status;
  final int index;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationCard({
    required this.employerName,
    required this.jobTitle,
    required this.status,
    required this.index,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = status == 'pending';

    return TweenAnimationBuilder<double>(
      key: ValueKey('$employerName-$jobTitle-$index'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 350 + (index.clamp(0, 5) * 80),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE5F5FA),
                        Color(0xFFDCEAF8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Color(0xFF136A84),
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
                          employerName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF172B4D),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Nhà tuyển dụng',
                          style: TextStyle(
                            color: Color(0xFF8493A7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 17),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEDF1F6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.work_outline_rounded,
                    color: Color(0xFF136A84),
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VỊ TRÍ PHỎNG VẤN',
                          style: TextStyle(
                            color: Color(0xFF8493A7),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          jobTitle,
                          style: const TextStyle(
                            color: Color(0xFF263B53),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 17),
              const Text(
                'Bạn có muốn tham gia phỏng vấn?',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        title: 'Từ chối lời mời?',
                        message:
                            'Bạn có chắc muốn từ chối lời mời phỏng vấn này không?',
                        confirmText: 'Từ chối',
                        confirmColor: const Color(0xFFD64545),
                        onConfirm: onReject,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD64545),
                        side: const BorderSide(
                          color: Color(0xFFF1CACA),
                        ),
                        backgroundColor: const Color(0xFFFFF8F8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        title: 'Chấp nhận lời mời?',
                        message:
                            'Bạn xác nhận muốn chấp nhận lời mời phỏng vấn này chứ?',
                        confirmText: 'Chấp nhận',
                        confirmColor: const Color(0xFF18865D),
                        onConfirm: onAccept,
                      ),
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 18,
                      ),
                      label: const Text('Chấp nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18865D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'accepted'
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      color: status == 'accepted'
                          ? const Color(0xFF18865D)
                          : const Color(0xFFD64545),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status == 'accepted'
                            ? 'Bạn đã chấp nhận lời mời này.'
                            : 'Bạn đã từ chối lời mời này.',
                        style: const TextStyle(
                          color: Color(0xFF52657A),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF172B4D),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final Color backgroundColor;
    late final IconData icon;
    late final String text;

    switch (status) {
      case 'accepted':
        color = const Color(0xFF18865D);
        backgroundColor = const Color(0xFFE5F7EE);
        icon = Icons.check_circle_rounded;
        text = 'Đã nhận';
        break;

      case 'rejected':
        color = const Color(0xFFD64545);
        backgroundColor = const Color(0xFFFFEEEE);
        icon = Icons.cancel_rounded;
        text = 'Đã từ chối';
        break;

      default:
        color = const Color(0xFFB7791F);
        backgroundColor = const Color(0xFFFFF4DB);
        icon = Icons.schedule_rounded;
        text = 'Chờ phản hồi';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE7EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A56).withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
              color: Color(0xFF136A84),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Đang tải lời mời phỏng vấn...',
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
                Icons.mark_email_unread_outlined,
                size: 52,
                color: Color(0xFF136A84),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có lời mời phỏng vấn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Khi doanh nghiệp mời bạn phỏng vấn, thông tin sẽ xuất hiện tại đây. Hãy tiếp tục khám phá các cơ hội phù hợp trên UniJob nhé!',
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
              'Không thể tải lời mời',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại sau.',
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
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_home_screen.dart';
import 'student_schedule_screen.dart';

// Màu sắc chủ đạo UniJob
const Color _primaryColor = Color(0xFF176B87);
const Color _accentColor = Color(0xFF2589D8);
const Color _backgroundColor = Color(0xFFF4F8FC);
const Color _textColor = Color(0xFF172B4D);
const Color _mutedColor = Color(0xFF718096);

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF17324D).withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FA),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, size: 42, color: _primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _mutedColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLoading() {
  return const Center(
    child: CircularProgressIndicator(
      color: _primaryColor,
      strokeWidth: 3,
    ),
  );
}

PreferredSizeWidget _buildAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    backgroundColor: _primaryColor,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(22),
      ),
    ),
  );
}

Widget _buildInfoRow(
  IconData icon,
  String label,
  dynamic value,
) {
  final String text = value?.toString().trim().isNotEmpty == true
      ? value.toString()
      : 'Chưa cập nhật';

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: _primaryColor),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: _textColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ======================================================
// MÀN HÌNH CHÍNH - 5 TAB
// ======================================================

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() =>
      _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    StudentHomeScreen(
      onNavigateToSchedule: () {
        setState(() {
          _currentIndex = 3;
        });
      },
    ),
    const StudentAcceptedRequestsTab(),
    const StudentJobsTab(),
    const StudentScheduleScreen(),
    const StudentFullProfileTab(),
  ];

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 2,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEAF5FA)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    selected ? activeIcon : icon,
                    color: selected
                        ? _primaryColor
                        : const Color(0xFF8795A5),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: selected
                        ? _primaryColor
                        : const Color(0xFF8795A5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF17324D).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(
                0,
                Icons.edit_note_rounded,
                Icons.edit_rounded,
                'Tạo CV',
              ),
              _buildNavItem(
                1,
                Icons.assignment_turned_in_outlined,
                Icons.assignment_turned_in_rounded,
                'Đơn duyệt',
              ),
              _buildNavItem(
                2,
                Icons.work_outline_rounded,
                Icons.work_rounded,
                'Việc làm',
              ),
              _buildNavItem(
                3,
                Icons.calendar_month_outlined,
                Icons.calendar_month_rounded,
                'Lịch trình',
              ),
              _buildNavItem(
                4,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// TAB 1: ĐƠN ĐÃ ĐƯỢC CHẤP NHẬN
// ======================================================

class StudentAcceptedRequestsTab extends StatefulWidget {
  const StudentAcceptedRequestsTab({super.key});

  @override
  State<StudentAcceptedRequestsTab> createState() =>
      _StudentAcceptedRequestsTabState();
}

class _StudentAcceptedRequestsTabState
    extends State<StudentAcceptedRequestsTab> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final Color _themeColor = _primaryColor;

  Future<void> _disconnectJob(String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        icon: const Icon(
          Icons.link_off_rounded,
          color: Colors.red,
          size: 34,
        ),
        title: const Text(
          'Xác nhận ngắt kết nối',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn ngắt kết nối khỏi đơn này không?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ngắt kết nối'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('job_requests')
          .doc(docId)
          .update({
        'status': 'pending',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã ngắt kết nối thành công. Đơn đã được chuyển về trang việc làm.',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem thông tin.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar('Đơn đã được chấp nhận'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('job_requests')
            .where(
              'studentId',
              isEqualTo: _currentUser!.uid,
            )
            .where(
              'status',
              isEqualTo: 'accepted',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Không thể tải dữ liệu',
              description: 'Vui lòng kiểm tra kết nối và thử lại.',
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Chưa có đơn được chấp nhận',
              description:
                  'Các đơn được chấp nhận sẽ xuất hiện tại đây.',
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              final String employerName =
                  data['employerName'] ??
                      data['companyName'] ??
                      'Công ty tuyển dụng';

              final String jobTitle =
                  data['jobTitle'] ??
                      data['title'] ??
                      'Vị trí tuyển dụng';

              final String acceptedTime =
                  data['acceptedAt'] ?? '19/09/2026';

              return TweenAnimationBuilder<double>(
                key: ValueKey(doc.id),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(
                  milliseconds:
                      300 + (index.clamp(0, 5).toInt() * 70),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  _primaryColor,
                                  _accentColor,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.work_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jobTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _textColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  employerName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _statusBadge(
                            'Đã chấp nhận',
                            Colors.green,
                            Icons.check_circle_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.access_time_rounded,
                              'Thời gian:',
                              acceptedTime,
                            ),
                            _buildInfoRow(
                              Icons.description_outlined,
                              'Mô tả:',
                              data['jobDescription'] ??
                                  data['description'] ??
                                  'Không có mô tả',
                            ),
                            _buildInfoRow(
                              Icons.payments_outlined,
                              'Mức lương:',
                              data['salary'] ?? 'Thỏa thuận',
                            ),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'Địa điểm:',
                              data['location'] ??
                                  'Chưa cập nhật',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _disconnectJob(doc.id),
                          icon: const Icon(
                            Icons.link_off_rounded,
                            size: 18,
                          ),
                          label: const Text('Ngắt kết nối'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(
                              color: Colors.red.withOpacity(0.35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================================================
// TAB 2: VIỆC LÀM ĐANG CHỜ PHẢN HỒI
// ======================================================

class StudentJobsTab extends StatefulWidget {
  const StudentJobsTab({super.key});

  @override
  State<StudentJobsTab> createState() =>
      _StudentJobsTabState();
}

class _StudentJobsTabState extends State<StudentJobsTab> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final Color _themeColor = _primaryColor;

  final Set<String> _processingIds = {};

  Future<void> _acceptJobRequest(String docId) async {
    if (_processingIds.contains(docId)) return;

    setState(() {
      _processingIds.add(docId);
    });

    try {
      await _firestore
          .collection('job_requests')
          .doc(docId)
          .update({
        'status': 'accepted',
        'acceptedAt': '19/09/2026',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã chấp nhận đơn! Đơn đã được chuyển sang tab Đơn đã duyệt.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(docId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem việc làm.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar('Việc làm UniJob'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('job_requests')
            .where(
              'studentId',
              isEqualTo: _currentUser!.uid,
            )
            .where(
              'status',
              isEqualTo: 'pending',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Không thể tải dữ liệu',
              description: 'Vui lòng kiểm tra kết nối và thử lại.',
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              icon: Icons.work_off_outlined,
              title: 'Chưa có lời mời việc làm',
              description:
                  'Khi doanh nghiệp gửi lời mời, thông tin sẽ xuất hiện tại đây.',
            );
          }

          final requests = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _primaryColor,
                      _accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cơ hội dành cho bạn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Bạn đang có ${requests.length} lời mời chờ phản hồi.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.rocket_launch_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              ...List.generate(requests.length, (index) {
                final doc = requests[index];
                final data =
                    doc.data() as Map<String, dynamic>;

                final String employerName =
                    data['employerName'] ??
                        data['companyName'] ??
                        'Công ty tuyển dụng';

                final String jobTitle =
                    data['jobTitle'] ??
                        data['title'] ??
                        'Vị trí tuyển dụng';

                final bool isProcessing =
                    _processingIds.contains(doc.id);

                return TweenAnimationBuilder<double>(
                  key: ValueKey(doc.id),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(
                    milliseconds:
                        300 + (index.clamp(0, 5).toInt() * 70),
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
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF5FA),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.business_center_rounded,
                                color: _primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jobTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    employerName,
                                    style: const TextStyle(
                                      color: _primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _statusBadge(
                          'Chờ phản hồi',
                          Colors.orange,
                          Icons.schedule_rounded,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.description_outlined,
                                'Mô tả:',
                                data['jobDescription'] ??
                                    data['description'] ??
                                    'Không có mô tả',
                              ),
                              _buildInfoRow(
                                Icons.payments_outlined,
                                'Mức lương:',
                                data['salary'] ?? 'Thỏa thuận',
                              ),
                              _buildInfoRow(
                                Icons.location_on_outlined,
                                'Địa điểm:',
                                data['location'] ??
                                    'Chưa cập nhật',
                              ),
                              _buildInfoRow(
                                Icons.calendar_month_outlined,
                                'Phỏng vấn:',
                                data['interviewSchedule'] ??
                                    data['schedule'] ??
                                    'Chờ thỏa thuận',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Thông tin doanh nghiệp chưa được tích hợp.',
                                      ),
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _primaryColor,
                                  side: const BorderSide(
                                    color: _primaryColor,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(13),
                                  ),
                                ),
                                child: const Text(
                                  'Xem doanh nghiệp',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isProcessing
                                    ? null
                                    : () => _acceptJobRequest(doc.id),
                                icon: isProcessing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  isProcessing
                                      ? 'Đang xử lý'
                                      : 'Chấp nhận',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      _primaryColor.withOpacity(0.6),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ======================================================
// TAB 4: HỒ SƠ SINH VIÊN
// ======================================================

class StudentFullProfileTab extends StatelessWidget {
  const StudentFullProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem hồ sơ.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar('Hồ sơ sinh viên'),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('students')
            .doc(currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Không thể tải hồ sơ',
              description: 'Vui lòng thử lại sau.',
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return _buildEmptyState(
              icon: Icons.person_outline_rounded,
              title: 'Chưa có thông tin hồ sơ',
              description:
                  'Vui lòng tạo CV tại tab Tạo CV để cập nhật hồ sơ của bạn.',
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _primaryColor,
                      _accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.65),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data['fullName'] ?? 'Chưa cập nhật tên',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        data['major'] ?? 'Công nghệ thông tin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 15,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Hồ sơ sinh viên UniJob',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileSection(
                icon: Icons.person_outline_rounded,
                title: 'Thông tin cá nhân',
                children: [
                  _buildInfoRow(
                    Icons.cake_outlined,
                    'Ngày sinh:',
                    data['dob'],
                  ),
                  _buildInfoRow(
                    Icons.wc_rounded,
                    'Giới tính:',
                    data['gender'],
                  ),
                  _buildInfoRow(
                    Icons.groups_rounded,
                    'Dân tộc:',
                    data['ethnicity'],
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Nơi ở:',
                    data['location'],
                  ),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email:',
                    data['email'],
                  ),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Điện thoại:',
                    data['phone'],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileSection(
                icon: Icons.school_outlined,
                title: 'Học vấn & kỹ năng',
                children: [
                  _buildInfoRow(
                    Icons.account_balance_outlined,
                    'Trường học:',
                    data['education'],
                  ),
                  _buildInfoRow(
                    Icons.menu_book_rounded,
                    'Chuyên ngành:',
                    data['major'],
                  ),
                  _buildInfoRow(
                    Icons.psychology_outlined,
                    'Kỹ năng:',
                    data['skills'],
                  ),
                  _buildInfoRow(
                    Icons.flag_outlined,
                    'Mục tiêu:',
                    data['objective'],
                  ),
                  _buildInfoRow(
                    Icons.favorite_border_rounded,
                    'Sở thích:',
                    data['hobbies'],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'UniJob • Kết nối đúng người, mở lối đúng cơ hội!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _primaryColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: _primaryColor.withOpacity(0.10),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ======================================================
// BADGE TRẠNG THÁI
// ======================================================

Widget _statusBadge(
  String text,
  Color color,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 9,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
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
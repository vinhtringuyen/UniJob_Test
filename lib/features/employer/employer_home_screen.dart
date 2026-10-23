import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'employer_search_screen.dart';
import 'employer_applications_screen.dart';
import 'employer_jobs_screen.dart';
import 'employer_profile_screen.dart';
import 'employer_schedule_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _currentIndex = 0;
  int _managementSubTab = 0; // 0: Lời mời đã gửi, 1: Đơn ứng tuyển, 2: Tin đã đăng

  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Color _primaryTeal = const Color(0xFF00A896);
  final Color _deepOcean = const Color(0xFF176B87);
  final Color _darkSlate = const Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _darkSlate.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryTeal, _deepOcean],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryTeal.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('employers')
                          .doc(currentUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String companyName = 'Công Ty TNHH TMDV UniJob';
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          companyName = data['companyName'] ?? companyName;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tài khoản Doanh nghiệp',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.blueGrey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: _darkSlate,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Nút mở nhanh trang Thiết lập Lịch làm việc (EmployerScheduleScreen)
                  Tooltip(
                    message: 'Thiết lập lịch ca làm mẫu',
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployerScheduleScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: _primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 18, color: _primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              'Lịch ca',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF334155),
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Bạn không có thông báo mới nào.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _deepOcean,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: _buildBodyContent(_currentIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: _primaryTeal,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Yêu cầu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_rounded),
              label: 'Tìm nhân sự',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_rounded),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(int index) {
    switch (index) {
      case 0:
        return _buildManagementDashboard();
      case 1:
        return const EmployerSearchScreen();
      case 2:
        return const EmployerProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- DASHBOARD QUẢN LÝ YÊU CẦU & TUYỂN DỤNG (TAB 0) ---
  Widget _buildManagementDashboard() {
    return Column(
      key: const ValueKey('dashboard_tab'),
      children: [
        // Banner lối tắt & tổng quan
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_deepOcean, _primaryTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _deepOcean.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TRUNG TÂM QUẢN LÝ TUYỂN DỤNG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Theo dõi kết nối & Hồ sơ ứng viên',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý lời mời làm việc đã gửi, duyệt đơn sinh viên và cập nhật tin đăng của bạn.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentIndex = 1),
                icon: Icon(Icons.person_search_rounded, size: 18, color: _deepOcean),
                label: Text(
                  'Tìm ứng viên',
                  style: TextStyle(
                    color: _deepOcean,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),

        // Thanh chuyển đổi 3 phân mục quản lý
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSubTabItem(0, Icons.send_rounded, 'Lời mời đã gửi'),
              ),
              Expanded(
                child: _buildSubTabItem(1, Icons.assignment_ind_rounded, 'Đơn ứng tuyển'),
              ),
              Expanded(
                child: _buildSubTabItem(2, Icons.work_outline_rounded, 'Tin tuyển dụng'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Nội dung chi tiết của từng phân mục
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildSubTabView(_managementSubTab),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabItem(int index, IconData icon, String label) {
    final bool isSelected = _managementSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _managementSubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? _primaryTeal : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? _darkSlate : const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabView(int subIndex) {
    switch (subIndex) {
      case 0:
        return _buildSentJobRequestsList();
      case 1:
        return const EmployerApplicationsScreen();
      case 2:
        return const EmployerJobsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // Danh sách các lời mời kết nối đã gửi từ trang Tìm Nhân Sự (collection 'job_requests')
  Widget _buildSentJobRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('job_requests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _primaryTeal));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mark_email_unread_outlined, size: 42, color: _primaryTeal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lời mời kết nối nào',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _darkSlate,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hãy sang mục "Tìm nhân sự" để lọc sinh viên phù hợp với lịch ca làm việc và gửi lời mời nhận việc.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _currentIndex = 1),
                    icon: const Icon(Icons.search_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'TÌM NHÂN SỰ NGAY',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryTeal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var docId = docs[index].id;
            var data = docs[index].data() as Map<String, dynamic>;

            String jobTitle = data['jobTitle'] ?? 'Tuyển dụng nhân sự';
            String salary = (data['salary'] ?? '').toString().trim().isNotEmpty
                ? data['salary']
                : 'Thỏa thuận';
            String location = (data['location'] ?? '').toString().trim().isNotEmpty
                ? data['location']
                : 'TP. Trà Vinh';
            String description = (data['jobDescription'] ?? '').toString().trim().isNotEmpty
                ? data['jobDescription']
                : 'Không có mô tả chi tiết';
            String status = (data['status'] ?? 'pending').toString().toLowerCase();

            Color statusColor = status == 'accepted' || status == 'approved'
                ? const Color(0xFF059669)
                : status == 'rejected'
                    ? const Color(0xFFE11D48)
                    : const Color(0xFFD97706);

            String statusText = status == 'accepted' || status == 'approved'
                ? 'Ứng viên đã đồng ý'
                : status == 'rejected'
                    ? 'Ứng viên từ chối'
                    : 'Đang chờ phản hồi';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _darkSlate.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: _primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.campaign_rounded, color: _primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jobTitle,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: _darkSlate,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Mã hồ sơ SV: ${data['studentId'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildInfoPill(Icons.payments_outlined, salary, const Color(0xFF059669)),
                      _buildInfoPill(Icons.location_on_outlined, location, _deepOcean),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('job_requests')
                              .doc(docId)
                              .delete();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã thu hồi lời mời kết nối.'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 17),
                        label: const Text(
                          'Thu hồi lời mời',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
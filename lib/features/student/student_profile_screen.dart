import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart'; // Trỏ đúng đến màn hình đăng nhập của bạn

const Color _primaryColor = Color(0xFF176B87);
const Color _accentColor = Color(0xFF2589D8);
const Color _backgroundColor = Color(0xFFF4F8FC);
const Color _textColor = Color(0xFF172B4D);
const Color _mutedColor = Color(0xFF718096);

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        icon: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.red,
            size: 30,
          ),
        ),
        title: const Text(
          'Đăng xuất tài khoản?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản UniJob không?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _mutedColor,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textColor,
              side: const BorderSide(color: Color(0xFFDCE5ED)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ở lại'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      // Điều hướng trực tiếp về trang LoginScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng xuất thất bại: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Nguyễn Vỉnh Trị';

    final String displayEmail = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : 'ngvtrihss277@gmail.com';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ sinh viên',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
        ),
        actions: [
          // Nút Đăng xuất trên góc phải AppBar
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryColor, _accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
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
                        color: Colors.white.withValues(alpha: 0.65),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.white,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Công nghệ thông tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          displayEmail,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Hồ sơ sinh viên UniJob',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Thông tin cá nhân',
            style: TextStyle(
              color: _textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // Thẻ chứa thông tin chi tiết
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE7EEF5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17324D).withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.cake_rounded, 'Ngày sinh:', '27/07/2006'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow(Icons.wc_rounded, 'Giới tính:', 'Nam'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow(Icons.people_alt_outlined, 'Dân tộc:', 'Kinh'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow(Icons.location_on_outlined, 'Nơi ở:', 'Trà Vinh'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow(Icons.email_outlined, 'Email:', displayEmail),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Nút Đăng xuất lớn ở cuối trang
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Đăng xuất tài khoản',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _primaryColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: _mutedColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _textColor,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
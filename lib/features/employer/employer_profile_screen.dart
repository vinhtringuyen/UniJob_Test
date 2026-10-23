import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'employer_schedule_screen.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final Color _primaryTeal = const Color(0xFF00A896);
  final Color _deepOcean = const Color(0xFF176B87);
  final Color _darkSlate = const Color(0xFF0F172A);

  // Hàm lấy thông tin, tự động tạo mới nếu chưa tồn tại trên Firestore để tránh lỗi trắng trang
  Future<Map<String, dynamic>> _fetchAndEnsureEmployerProfile() async {
    if (currentUser == null) return {};
    final uid = currentUser!.uid;

    final docRef = FirebaseFirestore.instance.collection('employers').doc(uid);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      return docSnap.data()!;
    }

    // Kiểm tra tiếp ở collection 'users'
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnap = await userDocRef.get();

    if (userSnap.exists && userSnap.data() != null) {
      return userSnap.data()!;
    }

    // Nếu hoàn toàn chưa có, tự động tạo bản ghi mặc định
    final defaultData = {
      'uid': uid,
      'companyName': 'Công Ty TNHH TMDV UniJob',
      'email': currentUser!.email ?? 'hr@unijob.vn',
      'phone': '0909123456',
      'taxCode': '1801234567',
      'contactName': 'Quản trị viên',
      'role': 'employer',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(defaultData, SetOptions(merge: true));
    return defaultData;
  }

  void _showEditProfileDialog(Map<String, dynamic> currentData) {
    final nameCtrl = TextEditingController(text: currentData['companyName'] ?? '');
    final phoneCtrl = TextEditingController(text: currentData['phone'] ?? currentData['phoneNumber'] ?? '');
    final contactCtrl = TextEditingController(text: currentData['contactName'] ?? '');
    final taxCtrl = TextEditingController(text: currentData['taxCode'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Cập nhật Hồ sơ Doanh nghiệp',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _darkSlate),
                  ),
                  const SizedBox(height: 18),
                  _buildTextField(nameCtrl, 'Tên công ty / Doanh nghiệp', Icons.apartment_rounded),
                  const SizedBox(height: 14),
                  _buildTextField(contactCtrl, 'Người đại diện liên hệ', Icons.person_outline_rounded),
                  const SizedBox(height: 14),
                  _buildTextField(phoneCtrl, 'Số điện thoại liên hệ', Icons.phone_outlined),
                  const SizedBox(height: 14),
                  _buildTextField(taxCtrl, 'Mã số thuế', Icons.receipt_long_outlined),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () async {
                      if (currentUser == null) return;
                      final uid = currentUser!.uid;
                      final updated = {
                        'companyName': nameCtrl.text.trim(),
                        'contactName': contactCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'taxCode': taxCtrl.text.trim(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('employers')
                          .doc(uid)
                          .set(updated, SetOptions(merge: true));

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã cập nhật thông tin thành công!'),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'LƯU THAY ĐỔI',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập tài khoản doanh nghiệp.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAndEnsureEmployerProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryTeal));
          }

          final userData = snapshot.data ?? {};
          final String companyName = userData['companyName'] ?? 'Công Ty TNHH TMDV UniJob';
          final String email = userData['email'] ?? currentUser!.email ?? 'hr@unijob.vn';
          final String phone = userData['phone'] ?? userData['phoneNumber'] ?? 'Chưa cập nhật SĐT';
          final String contactName = userData['contactName'] ?? 'Quản trị viên';
          final String taxCode = userData['taxCode'] ?? 'Chưa cập nhật MST';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              children: [
                // Thẻ thông tin công ty
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _darkSlate.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryTeal, _deepOcean],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryTeal.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.business_rounded, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: _darkSlate,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(userData),
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text(
                          'Chỉnh sửa thông tin công ty',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryTeal,
                          side: BorderSide(color: _primaryTeal.withValues(alpha: 0.5), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Thông tin liên hệ & pháp lý
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                      Text(
                        'THÔNG TIN LIÊN HỆ & PHÁP LÝ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey.shade400,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoTile(Icons.person_pin_outlined, 'Người đại diện', contactName),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _buildInfoTile(Icons.phone_in_talk_outlined, 'Số điện thoại', phone),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _buildInfoTile(Icons.receipt_long_outlined, 'Mã số thuế', taxCode),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tiện ích lịch ca làm việc
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _darkSlate.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployerScheduleScreen(),
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: _primaryTeal, size: 22),
                    ),
                    title: Text(
                      'Thiết lập Lịch làm việc mẫu',
                      style: TextStyle(fontWeight: FontWeight.w700, color: _darkSlate, fontSize: 15),
                    ),
                    subtitle: const Text(
                      'Cấu hình các khung giờ ca Sáng / Chiều / Tối',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 24),

                // Đăng xuất
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'ĐĂNG XUẤT TÀI KHOẢN',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: _deepOcean),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _darkSlate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:job_mekong/services/auth_service.dart';
import 'package:job_mekong/features/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  bool _isStudentRole = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _taxCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _contactNameController.dispose();
    _taxCodeController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phone = _phoneNumberController.text.trim();

    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ các thông tin chung bắt buộc!'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? errorResult;

    if (_isStudentRole) {
      if (_firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng điền đầy đủ thông tin cá nhân sinh viên!'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      errorResult = await _authService.registerStudent(
        email: email,
        password: password,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: email.split('@')[0],
        phoneNumber: phone,
      );
    } else {
      if (_companyNameController.text.trim().isEmpty ||
          _contactNameController.text.trim().isEmpty ||
          _taxCodeController.text.trim().isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng điền đầy đủ thông tin doanh nghiệp!'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      errorResult = await _authService.registerEmployer(
        email: email,
        password: password,
        companyName: _companyNameController.text.trim(),
        contactName: _contactNameController.text.trim(),
        taxCode: _taxCodeController.text.trim(),
        phoneNumber: phone,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorResult),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color studentColor = Color(0xFF176B87);
    const Color employerColor = Color(0xFF00A896);
    final Color activeColor = _isStudentRole ? studentColor : employerColor;
    const Color textColor = Color(0xFF1E293B);
    const Color bgColor = Color(0xFFF4F7FB);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Tạo tài khoản mới',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- THANH CHỌN VAI TRÒ CÓ HIỆU ỨNG ĐỘNG ---
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isStudentRole = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: _isStudentRole ? studentColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: _isStudentRole
                                  ? [
                                      BoxShadow(
                                        color: studentColor.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 18,
                                  color: _isStudentRole ? Colors.white : Colors.blueGrey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sinh viên',
                                  style: TextStyle(
                                    color: _isStudentRole ? Colors.white : Colors.blueGrey.shade600,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isStudentRole = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: !_isStudentRole ? employerColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: !_isStudentRole
                                  ? [
                                      BoxShadow(
                                        color: employerColor.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business_center_rounded,
                                  size: 18,
                                  color: !_isStudentRole ? Colors.white : Colors.blueGrey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Doanh nghiệp',
                                  style: TextStyle(
                                    color: !_isStudentRole ? Colors.white : Colors.blueGrey.shade600,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- KHUNG FORM ĐĂNG KÝ ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withValues(alpha: 0.07),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chuyển đổi mượt giữa các trường Sinh viên và Doanh nghiệp
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _isStudentRole
                            ? _buildStudentFields(activeColor)
                            : _buildEmployerFields(activeColor),
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: _inputDecoration(
                          hint: 'Nhập địa chỉ email',
                          icon: Icons.email_outlined,
                          activeColor: activeColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Số điện thoại'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: _inputDecoration(
                          hint: 'Nhập số điện thoại liên hệ',
                          icon: Icons.phone_outlined,
                          activeColor: activeColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Mật khẩu'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: _inputDecoration(
                          hint: 'Tối thiểu 6 ký tự',
                          icon: Icons.lock_outline_rounded,
                          activeColor: activeColor,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.blueGrey.shade300,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- NÚT ĐĂNG KÝ ---
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _isStudentRole
                                ? const [Color(0xFF176B87), Color(0xFF288FB4)]
                                : const [Color(0xFF00A896), Color(0xFF43C6AC)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'HOÀN TẤT ĐĂNG KÝ',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentFields(Color activeColor) {
    return Row(
      key: const ValueKey('student_fields'),
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Họ'),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint: 'Nguyễn...',
                  icon: Icons.badge_outlined,
                  activeColor: activeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tên'),
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint: 'Nhập tên',
                  icon: Icons.person_outline_rounded,
                  activeColor: activeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployerFields(Color activeColor) {
    return Column(
      key: const ValueKey('employer_fields'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Tên công ty'),
        const SizedBox(height: 8),
        TextField(
          controller: _companyNameController,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: _inputDecoration(
            hint: 'Nhập tên doanh nghiệp / công ty',
            icon: Icons.apartment_rounded,
            activeColor: activeColor,
          ),
        ),
        const SizedBox(height: 18),
        _buildLabel('Người liên hệ'),
        const SizedBox(height: 8),
        TextField(
          controller: _contactNameController,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: _inputDecoration(
            hint: 'Nhập họ tên người đại diện',
            icon: Icons.person_pin_outlined,
            activeColor: activeColor,
          ),
        ),
        const SizedBox(height: 18),
        _buildLabel('Mã số thuế'),
        const SizedBox(height: 8),
        TextField(
          controller: _taxCodeController,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: _inputDecoration(
            hint: 'Nhập mã số thuế doanh nghiệp',
            icon: Icons.receipt_long_outlined,
            activeColor: activeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color activeColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 20),
       suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.blueGrey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: activeColor,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.6,
        ),
      ),
    );
  }
}
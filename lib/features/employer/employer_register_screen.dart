import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployerRegisterScreen extends StatefulWidget {
  const EmployerRegisterScreen({super.key});

  @override
  State<EmployerRegisterScreen> createState() => _EmployerRegisterScreenState();
}

class _EmployerRegisterScreenState extends State<EmployerRegisterScreen> {
  final Color primaryColor = const Color(0xFF00A896);
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _registerEmployer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('employers').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'companyName': _companyNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'employer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng ký tài khoản doanh nghiệp thành công!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đã có lỗi xảy ra';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng cho tài khoản khác.';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Đăng Ký Doanh Nghiệp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.07), blurRadius: 30, offset: const Offset(0, 14)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tạo tài khoản đối tác', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaryColor)),
                  const SizedBox(height: 6),
                  Text('Đăng ký để tuyển dụng nhân sự chất lượng cao', style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 14)),
                  const SizedBox(height: 28),
                  
                  const Text('Tên công ty / Doanh nghiệp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: _inputDecoration('Nhập tên doanh nghiệp', Icons.business_rounded),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
                  ),
                  const SizedBox(height: 18),

                  const Text('Số điện thoại liên hệ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Nhập số điện thoại', Icons.phone_rounded),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 18),

                  const Text('Email công ty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('hr@congty.com', Icons.email_rounded),
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Vui lòng nhập email hợp lệ' : null,
                  ),
                  const SizedBox(height: 18),

                  const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Tối thiểu 6 ký tự',
                      hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: Icon(Icons.lock_rounded, color: Colors.blueGrey.shade400, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.blueGrey.shade300,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1.2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryColor, width: 1.8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) => value!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                  ),
                  const SizedBox(height: 28),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A896), Color(0xFF43C6AC)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerEmployer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryColor, width: 1.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
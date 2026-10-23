import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/student_service.dart';

class StudentHomeScreen extends StatefulWidget {
  // Giữ nguyên callback điều hướng sang tab Lịch trình.
  final Function()? onNavigateToSchedule;

  const StudentHomeScreen({
    super.key,
    this.onNavigateToSchedule,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF176B87);
  static const Color secondaryColor = Color(0xFF2589D8);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF172B4D);
  static const Color mutedColor = Color(0xFF718096);

  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ethnicityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;
  bool _isEditing = false;

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();
    _loadExistingStudentData();
  }

  @override
  void dispose() {
    _introController.dispose();

    _fullNameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _ethnicityController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _educationController.dispose();
    _majorController.dispose();
    _skillsController.dispose();
    _objectiveController.dispose();
    _hobbiesController.dispose();

    super.dispose();
  }

  // Giữ nguyên đường dẫn và cách đọc dữ liệu Firestore.
  Future<void> _loadExistingStudentData() async {
    if (_currentUser == null) {
      if (mounted) {
        setState(() => _isFetching = false);
      }
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;

        _fullNameController.text = data['fullName'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _genderController.text = data['gender'] ?? '';
        _ethnicityController.text = data['ethnicity'] ?? '';
        _locationController.text = data['location'] ?? '';
        _emailController.text =
            data['email'] ?? _currentUser!.email ?? '';
        _phoneController.text = data['phone'] ?? '';
        _educationController.text =
            data['education'] ?? 'Đại học Trà Vinh';
        _majorController.text =
            data['major'] ?? 'Công nghệ thông tin';
        _skillsController.text = data['skills'] ?? '';
        _objectiveController.text = data['objective'] ?? '';
        _hobbiesController.text = data['hobbies'] ?? '';

        if ((data['fullName'] ?? '').toString().isNotEmpty && mounted) {
          setState(() {
            _isEditing = true;
          });
        }
      } else {
        _emailController.text = _currentUser!.email ?? '';
      }
    } catch (e) {
      // Giữ nguyên cách xử lý lỗi của màn hình hiện tại.
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  // Giữ nguyên StudentService, dữ liệu gửi đi và callback điều hướng.
  Future<void> _submitAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = false;

    try {
      success = await _studentService.saveStudentCV(
        fullName: _fullNameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _genderController.text.trim(),
        ethnicity: _ethnicityController.text.trim(),
        location: _locationController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        education: _educationController.text.trim(),
        major: _majorController.text.trim(),
        skills: _skillsController.text.trim(),
        objective: _objectiveController.text.trim(),
        hobbies: _hobbiesController.text.trim(),
      );
    } catch (e) {
      success = false;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lưu thông tin CV thành công! Đang chuyển sang lịch trình...',
          ),
          backgroundColor: Color(0xFF18865D),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );

      if (widget.onNavigateToSchedule != null) {
        widget.onNavigateToSchedule!();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thất bại, vui lòng kiểm tra lại!'),
          backgroundColor: Color(0xFFD64545),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Đang chuẩn bị hồ sơ của bạn...',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Hồ sơ CV của tôi' : 'Tạo hồ sơ CV',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Xây dựng hồ sơ, mở rộng cơ hội',
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
              height: 90,
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
          SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),

                      _buildSectionCard(
                        title: 'Thông tin cá nhân',
                        subtitle: 'Thông tin để doanh nghiệp liên hệ với bạn',
                        icon: Icons.badge_rounded,
                        sectionNumber: '01',
                        children: [
                          _buildField(
                            controller: _fullNameController,
                            label: 'Họ và tên',
                            hint: 'Nhập họ và tên đầy đủ',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                _validateRequired(v, 'họ và tên'),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 17),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _dobController,
                                  label: 'Ngày sinh',
                                  hint: 'DD/MM/YYYY',
                                  icon: Icons.calendar_month_rounded,
                                  validator: (v) =>
                                      _validateRequired(v, 'ngày sinh'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _genderController,
                                  label: 'Giới tính',
                                  hint: 'Nhập giới tính',
                                  icon: Icons.wc_rounded,
                                  validator: (v) =>
                                      _validateRequired(v, 'giới tính'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _ethnicityController,
                                  label: 'Dân tộc',
                                  hint: 'Nhập dân tộc',
                                  icon: Icons.groups_outlined,
                                  validator: (v) =>
                                      _validateRequired(v, 'dân tộc'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _locationController,
                                  label: 'Nơi ở',
                                  hint: 'Nhập nơi ở',
                                  icon: Icons.location_on_outlined,
                                  validator: (v) =>
                                      _validateRequired(v, 'nơi ở'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _emailController,
                            label: 'Email liên hệ',
                            hint: 'example@email.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                _validateRequired(v, 'email'),
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            hint: 'Nhập số điện thoại',
                            icon: Icons.phone_iphone_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                _validateRequired(v, 'số điện thoại'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _buildSectionCard(
                        title: 'Học vấn & Kỹ năng',
                        subtitle: 'Thể hiện năng lực và kiến thức của bạn',
                        icon: Icons.school_rounded,
                        sectionNumber: '02',
                        children: [
                          _buildField(
                            controller: _educationController,
                            label: 'Trường học',
                            hint: 'Ví dụ: Đại học Trà Vinh',
                            icon: Icons.account_balance_outlined,
                            validator: (v) =>
                                _validateRequired(v, 'trường học'),
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _majorController,
                            label: 'Chuyên ngành',
                            hint: 'Ví dụ: Công nghệ thông tin',
                            icon: Icons.menu_book_rounded,
                            validator: (v) =>
                                _validateRequired(v, 'chuyên ngành'),
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _skillsController,
                            label: 'Kỹ năng',
                            hint: 'Ví dụ: Flutter, C++, SQL, giao tiếp...',
                            icon: Icons.code_rounded,
                            validator: (v) =>
                                _validateRequired(v, 'kỹ năng'),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _objectiveController,
                            label: 'Mục tiêu nghề nghiệp',
                            hint: 'Bạn muốn phát triển bản thân như thế nào?',
                            icon: Icons.flag_outlined,
                            validator: (v) => _validateRequired(
                              v,
                              'mục tiêu nghề nghiệp',
                            ),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 17),
                          _buildField(
                            controller: _hobbiesController,
                            label: 'Sở thích cá nhân',
                            hint: 'Ví dụ: Công nghệ, đọc sách, thể thao...',
                            icon: Icons.favorite_border_rounded,
                            validator: (v) =>
                                _validateRequired(v, 'sở thích'),
                            maxLines: 2,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildSaveButton(),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Color(0xFF8A9AAF),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Thông tin của bạn được sử dụng để xây dựng hồ sơ UniJob.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -40,
            child: _HeaderCircle(
              size: 130,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Positioned(
            right: 36,
            bottom: -54,
            child: _HeaderCircle(
              size: 100,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hồ sơ năng lực UniJob',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _isEditing
                              ? 'Cập nhật thông tin của bạn'
                              : 'Bắt đầu hành trình nghề nghiệp',
                          style: const TextStyle(
                            color: Color(0xFFE0F2F7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.13),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: Color(0xFFFFE6A7),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Một hồ sơ rõ ràng giúp doanh nghiệp hiểu hơn về bạn và tìm được ứng viên phù hợp.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.55,
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

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String sectionNumber,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A56).withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.13),
                      secondaryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                sectionNumber,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.30),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            height: 1,
            color: const Color(0xFFEDF1F6),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFA0AEC0),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF718096),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4, right: 2),
          child: Icon(
            icon,
            color: primaryColor.withOpacity(0.8),
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD64545),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD64545),
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF176B87),
            Color(0xFF2589D8),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.23),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAndSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const Row(
                  key: ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ĐANG LƯU HỒ SƠ...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('save'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.save_rounded,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isEditing ? 'CẬP NHẬT HỒ SƠ CV' : 'LƯU HỒ SƠ CV',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _HeaderCircle({
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
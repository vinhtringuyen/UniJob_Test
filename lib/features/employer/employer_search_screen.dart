import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerSearchScreen extends StatefulWidget {
  final bool showAppBar;
  const EmployerSearchScreen({super.key, this.showAppBar = true});

  @override
  State<EmployerSearchScreen> createState() => _EmployerSearchScreenState();
}

class _EmployerSearchScreenState extends State<EmployerSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers thông tin tuyển dụng
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Tiêu chí chọn chi tiết
  String _selectedGender = 'Tất cả';
  String _selectedLevel = 'Tất cả';
  String _selectedMajor = 'Tất cả';

  final List<String> _genderOptions = ['Tất cả', 'Nam', 'Nữ'];
  final List<String> _levelOptions = [
    'Tất cả',
    'Năm 1',
    'Năm 2',
    'Năm 3',
    'Năm 4',
    'Đã tốt nghiệp'
  ];
  final List<String> _majorOptions = [
    'Tất cả',
    'Công nghệ thông tin',
    'Quản trị kinh doanh',
    'Ngôn ngữ Anh',
    'Kế toán - Tài chính',
    'Y - Dược',
    'Ngành khác'
  ];

  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final Map<String, Set<String>> _scheduleData = {};

  List<Map<String, dynamic>> _candidates = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final Color _themeColor = const Color(0xFF00897B);
  final Color _deepOcean = const Color(0xFF176B87);
  final Color _darkText = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getWeekdayLabel(int weekday) {
    const map = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    return map[weekday] ?? '';
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  void _toggleShift(String shiftId) {
    String dateKey = _formatDateKey(_selectedDate);
    setState(() {
      _scheduleData.putIfAbsent(dateKey, () => {});
      if (_scheduleData[dateKey]!.contains(shiftId)) {
        _scheduleData[dateKey]!.remove(shiftId);
        if (_scheduleData[dateKey]!.isEmpty) _scheduleData.remove(dateKey);
      } else {
        _scheduleData[dateKey]!.add(shiftId);
      }
    });
  }

  bool _isShiftSelected(String shiftId) {
    String dateKey = _formatDateKey(_selectedDate);
    return _scheduleData[dateKey]?.contains(shiftId) ?? false;
  }

  int _getTotalSelectedDays() =>
      _scheduleData.keys.where((k) => _scheduleData[k]!.isNotEmpty).length;

  int _getTotalSelectedShifts() {
    int count = 0;
    for (var s in _scheduleData.values) {
      count += s.length;
    }
    return count;
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'UV';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // --- LẤY DỮ LIỆU TỪ FIRESTORE (GIỮ NGUYÊN 100% THUẬT TOÁN CỦA BẠN) ---
  Future<void> _searchCandidates() async {
    FocusScope.of(context).unfocus();
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vui lòng nhập Vị trí tuyển dụng trước khi tìm kiếm!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('students').get();
      List<Map<String, dynamic>> matchedList = [];
      List<String> skillKeywords = _skillsController.text
          .toLowerCase()
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};

        String studentName = data['fullName'] ?? 'Sinh viên chưa cập nhật tên';
        String studentGender = data['gender'] ?? 'Chưa rõ';
        String studentMajor = data['major'] ?? 'Chưa rõ';
        String studentPhone = data['phone'] ?? 'Chưa có SĐT';
        String studentEmail = data['email'] ?? 'Chưa có Email';
        String studentDob = data['dob'] ?? 'Chưa cập nhật';
        String studentEducation = data['education'] ?? 'Chưa cập nhật';
        String studentLocation = data['location'] ?? 'Chưa cập nhật';
        String studentObjective = data['objective'] ?? 'Chưa cập nhật';
        String studentHobbies = data['hobbies'] ?? 'Chưa cập nhật';
        String studentSkills = data['skills'] ?? 'Chưa cập nhật kỹ năng';

        Map<String, dynamic> studentSchedules = {};
        if (data['schedules'] is Map) {
          studentSchedules = Map<String, dynamic>.from(data['schedules']);
        }

        int totalCriteria = 0;
        int matchedCriteria = 0;

        // 1. Khớp Lịch
        _scheduleData.forEach((dateKey, requiredShifts) {
          for (String shift in requiredShifts) {
            totalCriteria++;
            if (studentSchedules.containsKey(dateKey)) {
              List<dynamic> studentShifts = studentSchedules[dateKey] ?? [];
              if (studentShifts.contains(shift)) matchedCriteria++;
            }
          }
        });

        // 2. Khớp kỹ năng
        if (skillKeywords.isNotEmpty) {
          for (String skill in skillKeywords) {
            totalCriteria++;
            if (studentSkills.toLowerCase().contains(skill) ||
                studentObjective.toLowerCase().contains(skill)) {
              matchedCriteria++;
            }
          }
        }

        // 3. Khớp Giới tính & Ngành
        if (_selectedGender != 'Tất cả') {
          totalCriteria++;
          if (studentGender.toLowerCase() == _selectedGender.toLowerCase()) {
            matchedCriteria++;
          }
        }
        if (_selectedMajor != 'Tất cả') {
          totalCriteria++;
          if (studentMajor.toLowerCase().contains(_selectedMajor.toLowerCase())) {
            matchedCriteria++;
          }
        }

        int matchPercentage = totalCriteria == 0
            ? 100
            : ((matchedCriteria / totalCriteria) * 100).round();
        if (matchPercentage > 100) matchPercentage = 100;

        matchedList.add({
          'id': doc.id,
          'fullName': studentName,
          'gender': studentGender,
          'major': studentMajor,
          'phone': studentPhone,
          'email': studentEmail,
          'dob': studentDob,
          'education': studentEducation,
          'location': studentLocation,
          'objective': studentObjective,
          'hobbies': studentHobbies,
          'skills': studentSkills,
          'level': data['level'] ?? 'Sinh viên',
          'matchPercentage': matchPercentage,
        });
      }

      matchedList.sort((a, b) =>
          (b['matchPercentage'] as int).compareTo(a['matchPercentage'] as int));

      setState(() {
        _candidates = matchedList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi: $e'), backgroundColor: Colors.redAccent),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // --- BOTTOM SHEET HIỂN THỊ ĐẦY ĐỦ THÔNG TIN ỨNG VIÊN ---
  void _showCandidateDetails(Map<String, dynamic> candidate) {
    int percentage = candidate['matchPercentage'] ?? 0;
    Color badgeColor = percentage >= 80
        ? const Color(0xFF059669)
        : (percentage >= 50 ? const Color(0xFFD97706) : const Color(0xFFE11D48));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header ứng viên
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00A896), Color(0xFF176B87)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _themeColor.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(candidate['fullName'] ?? ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate['fullName'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${candidate['major']} • ${candidate['level']}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Độ khớp',
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // Grid thông tin nhanh
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickStatCard(
                              Icons.cake_rounded,
                              'Ngày sinh',
                              candidate['dob'],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickStatCard(
                              Icons.wc_rounded,
                              'Giới tính',
                              candidate['gender'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildDetailRow(Icons.school_rounded, 'Trường đào tạo', candidate['education']),
                      _buildDetailRow(Icons.menu_book_rounded, 'Chuyên ngành', candidate['major']),
                      _buildDetailRow(Icons.phone_in_talk_rounded, 'Số điện thoại', candidate['phone']),
                      _buildDetailRow(Icons.alternate_email_rounded, 'Địa chỉ Email', candidate['email']),
                      _buildDetailRow(Icons.location_on_rounded, 'Khu vực hiện tại', candidate['location']),
                      _buildDetailRow(Icons.auto_awesome_rounded, 'Kỹ năng chuyên môn', candidate['skills']),
                      _buildDetailRow(Icons.flag_rounded, 'Mục tiêu nghề nghiệp', candidate['objective']),
                      _buildDetailRow(Icons.favorite_rounded, 'Sở thích cá nhân', candidate['hobbies']),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Đóng',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00A896), Color(0xFF176B87)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _themeColor.withValues(alpha: 0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _sendConnectionRequest(candidate);
                                },
                                icon: const Icon(Icons.handshake_rounded, size: 19, color: Colors.white),
                                label: const Text(
                                  'GỬI LỜI MỜI KẾT NỐI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
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
        );
      },
    );
  }

  Widget _buildQuickStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _themeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: _deepOcean),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- GỬI YÊU CẦU LÊN FIRESTORE (GIỮ NGUYÊN LOGIC CỦA BẠN) ---
  Future<void> _sendConnectionRequest(Map<String, dynamic> candidate) async {
    try {
      await _firestore.collection('job_requests').add({
        'studentId': candidate['id'],
        'employerId': 'CongTyTNHH_UniJob',
        'employerName': 'Công Ty TNHH TMDV UniJob',
        'jobTitle': _titleController.text.isNotEmpty
            ? _titleController.text
            : 'Tuyển dụng nhân sự',
        'jobDescription': _descriptionController.text,
        'salary': _salaryController.text,
        'location': _locationController.text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã gửi lời mời làm việc đến ${candidate['fullName']}!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi gửi request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi kết nối: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 19, color: const Color(0xFF64748B))
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _themeColor, width: 1.8),
      ),
    );
  }

  Widget _buildSectionBox({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A896), Color(0xFF176B87)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BƯỚC $stepNumber',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _themeColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: _inputDecoration(hint: hint, prefixIcon: icon),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text(
                  'Thiết Lập Yêu Cầu Tuyển Dụng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                backgroundColor: Colors.white,
                foregroundColor: _darkText,
                centerTitle: true,
                elevation: 0,
              )
            : null,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- BƯỚC 1: THÔNG TIN VỊ TRÍ & ĐÃI NGỘ ---
              _buildSectionBox(
                stepNumber: '01',
                title: 'Thông tin vị trí & Đãi ngộ',
                subtitle: 'Nhập chi tiết công việc để thu hút đúng ứng viên mục tiêu.',
                icon: Icons.work_outline_rounded,
                child: Column(
                  children: [
                    _buildInputTile(
                      controller: _titleController,
                      label: 'Vị trí tuyển dụng (*)',
                      hint: 'VD: Lập trình viên Flutter, Thu ngân, Gia sư...',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildInputTile(
                      controller: _descriptionController,
                      label: 'Mô tả công việc chi tiết',
                      hint: 'Mô tả các đầu việc chính, quyền lợi hoặc phụ cấp...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputTile(
                            controller: _salaryController,
                            label: 'Mức lương đề xuất',
                            hint: '25.000đ/giờ',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputTile(
                            controller: _locationController,
                            label: 'Địa điểm làm việc',
                            hint: 'TP. Trà Vinh',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- BƯỚC 2: TIÊU CHUẨN HỒ SƠ ỨNG VIÊN ---
              _buildSectionBox(
                stepNumber: '02',
                title: 'Tiêu chuẩn hồ sơ ứng viên',
                subtitle: 'Hệ thống tự động tính điểm % độ khớp theo tiêu chí này.',
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giới tính ưu tiên',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _genderOptions.map((gender) {
                        bool isSelected = _selectedGender == gender;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: gender != _genderOptions.last ? 10 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGender = gender),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFF00A896), Color(0xFF176B87)],
                                        )
                                      : null,
                                  color: isSelected ? null : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chuyên ngành',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedMajor,
                                isExpanded: true,
                                decoration: _inputDecoration(),
                                items: _majorOptions
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(
                                            m,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedMajor = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trình độ / Năm học',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedLevel,
                                isExpanded: true,
                                decoration: _inputDecoration(),
                                items: _levelOptions
                                    .map((l) => DropdownMenuItem(
                                          value: l,
                                          child: Text(
                                            l,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedLevel = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputTile(
                      controller: _skillsController,
                      label: 'Từ khóa kỹ năng (ngăn cách bởi dấu phẩy)',
                      hint: 'VD: Flutter, Tiếng Anh, Giao tiếp, Photoshop...',
                      icon: Icons.auto_awesome_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- BƯỚC 3: LỊCH LÀM VIỆC YÊU CẦU ---
              _buildSectionBox(
                stepNumber: '03',
                title: 'Lịch làm việc yêu cầu',
                subtitle:
                    'Đã chọn ${_getTotalSelectedDays()} ngày (${_getTotalSelectedShifts()} ca làm việc)',
                icon: Icons.calendar_month_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Tháng ${_currentMonth.month.toString().padLeft(2, '0')} / ${_currentMonth.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _themeColor,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _changeMonth(-1),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(Icons.chevron_left_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _changeMonth(1),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(Icons.chevron_right_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 74,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          DateTime day = DateTime(
                              _currentMonth.year, _currentMonth.month, index + 1);
                          bool isSelected = day.day == _selectedDate.day &&
                              day.month == _selectedDate.month &&
                              day.year == _selectedDate.year;
                          String dateKey = _formatDateKey(day);
                          int shiftCount = _scheduleData[dateKey]?.length ?? 0;
                          bool hasShifts = shiftCount > 0;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF00A896), Color(0xFF176B87)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (hasShifts
                                        ? _themeColor.withValues(alpha: 0.1)
                                        : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (hasShifts
                                          ? _themeColor
                                          : const Color(0xFFE2E8F0)),
                                  width: 1.4,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _themeColor.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getWeekdayLabel(day.weekday),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : (hasShifts ? _themeColor : _darkText),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  if (hasShifts)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        shiftCount,
                                        (_) => Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.white : _themeColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ca làm ngày ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _darkText,
                          ),
                        ),
                        if (_scheduleData.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _scheduleData.clear()),
                            child: const Text(
                              'Xóa tất cả lịch',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE11D48),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildShiftCard(
                          'morning',
                          'Ca Sáng',
                          '07:00 - 11:30',
                          Icons.wb_twilight_rounded,
                          const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 10),
                        _buildShiftCard(
                          'afternoon',
                          'Ca Chiều',
                          '13:00 - 17:00',
                          Icons.wb_sunny_rounded,
                          const Color(0xFFEA580C),
                        ),
                        const SizedBox(width: 10),
                        _buildShiftCard(
                          'evening',
                          'Ca Tối',
                          '18:00 - 22:00',
                          Icons.nightlight_round,
                          const Color(0xFF4F46E5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- NÚT TÌM KIẾM ỨNG VIÊN ---
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A896), Color(0xFF176B87)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _themeColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchCandidates,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.radar_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isLoading
                        ? 'ĐANG PHÂN TÍCH & ĐỐI CHIẾU HỒ SƠ...'
                        : 'TÌM KIẾM ỨNG VIÊN PHÙ HỢP',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              // --- KẾT QUẢ PHÙ HỢP ---
              if (_hasSearched) ...[
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _themeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Ứng Viên Đề Xuất',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _darkText,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _deepOcean.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_candidates.length} kết quả',
                        style: TextStyle(
                          color: _deepOcean,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_candidates.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Colors.blueGrey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa tìm thấy ứng viên phù hợp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hãy thử nới lỏng tiêu chí lọc hoặc chọn ít ca làm việc hơn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 280 + (index * 60).clamp(0, 300)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Opacity(
                            opacity: val,
                            child: Transform.translate(
                              offset: Offset(0, 18 * (1 - val)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildCandidateCard(_candidates[index]),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftCard(
    String shiftId,
    String title,
    String timeText,
    IconData icon,
    Color iconColor,
  ) {
    bool selected = _isShiftSelected(shiftId);
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleShift(shiftId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _themeColor.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _themeColor : const Color(0xFFE2E8F0),
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? _themeColor : iconColor,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? _themeColor : _darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    int percentage = candidate['matchPercentage'] ?? 0;
    Color badgeColor = percentage >= 80
        ? const Color(0xFF059669)
        : (percentage >= 50 ? const Color(0xFFD97706) : const Color(0xFFE11D48));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showCandidateDetails(candidate),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A896), Color(0xFF176B87)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(candidate['fullName'] ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate['fullName'],
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              color: _darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildMiniTag(Icons.school_outlined, candidate['major']),
                              _buildMiniTag(Icons.person_outline, candidate['gender']),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Vòng tròn hiển thị % độ khớp
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: badgeColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                            strokeWidth: 4.5,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Mục tiêu: ${candidate['objective']}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCandidateDetails(candidate),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text(
                        'Xem hồ sơ',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _sendConnectionRequest(candidate),
                      icon: const Icon(Icons.send_rounded, size: 15, color: Colors.white),
                      label: const Text(
                        'Gửi lời mời',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
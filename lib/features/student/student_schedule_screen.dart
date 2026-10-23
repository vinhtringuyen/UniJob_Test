import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() =>
      _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen>
    with WidgetsBindingObserver {
  static const Color primaryColor = Color(0xFF176B87);
  static const Color accentColor = Color(0xFF2589D8);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF172B4D);
  static const Color mutedColor = Color(0xFF718096);

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final Map<DateTime, List<String>> _selectedSchedules = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadExistingSchedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingSchedule();
  }

  Future<void> _loadExistingSchedule() async {
    if (_currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final schedules = data['schedules'];

        if (schedules is Map) {
          final Map<DateTime, List<String>> loadedSchedules = {};

          schedules.forEach((dateStr, sessions) {
            final parts = dateStr.toString().split('-');

            if (parts.length == 3 && sessions is List) {
              final year = int.tryParse(parts[0]);
              final month = int.tryParse(parts[1]);
              final day = int.tryParse(parts[2]);

              if (year != null && month != null && day != null) {
                final date = DateTime(year, month, day);
                loadedSchedules[date] = List<String>.from(sessions);
              }
            }
          });

          if (mounted) {
            setState(() {
              _selectedSchedules
                ..clear()
                ..addAll(loadedSchedules);
            });
          }
        } else if (mounted) {
          setState(() => _selectedSchedules.clear());
        }
      }
    } catch (e) {
      // Giữ nguyên cách xử lý lỗi tải lịch.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
        1,
      );
    });
  }

  void _toggleSession(String session) {
    final selected = _normalizeDate(_selectedDate);

    setState(() {
      _selectedSchedules.putIfAbsent(selected, () => []);

      if (_selectedSchedules[selected]!.contains(session)) {
        _selectedSchedules[selected]!.remove(session);

        if (_selectedSchedules[selected]!.isEmpty) {
          _selectedSchedules.remove(selected);
        }
      } else {
        _selectedSchedules[selected]!.add(session);
      }
    });
  }

  Future<void> _saveSchedule() async {
    if (_currentUser == null) {
      _showMessage('Vui lòng đăng nhập để lưu lịch.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, List<String>> scheduleDataToSave = {};

      _selectedSchedules.forEach((date, sessions) {
        if (sessions.isNotEmpty) {
          final dateString =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';

          scheduleDataToSave[dateString] = List<String>.from(sessions);
        }
      });

      await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentUser!.uid)
          .update({
        'schedules': scheduleDataToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadExistingSchedule();

      if (mounted) {
        _showMessage(
          'Đã cập nhật lịch rảnh thành công!',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Lỗi khi lưu lịch: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF16845B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _monthName {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];

    return '${months[_focusedMonth.month - 1]} / ${_focusedMonth.year}';
  }

  String get _selectedDateLabel {
    return '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
  }

  int get _selectedDayCount => _selectedSchedules.values
      .where((sessions) => sessions.isNotEmpty)
      .length;

  int get _selectedSessionCount => _selectedSchedules.values.fold(
        0,
        (total, sessions) => total + sessions.length,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch rảnh của tôi',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Chủ động sắp xếp thời gian làm việc',
              style: TextStyle(
                fontSize: 12,
                color: mutedColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 22),
                        _buildSectionHeading(
                          icon: Icons.calendar_month_rounded,
                          title: 'Chọn ngày',
                          subtitle: 'Chọn ngày bạn có thể đi làm',
                        ),
                        const SizedBox(height: 12),
                        _buildCalendarCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeading(
                          icon: Icons.schedule_rounded,
                          title: 'Khung giờ làm việc',
                          subtitle: 'Ngày $_selectedDateLabel',
                        ),
                        const SizedBox(height: 12),
                        _buildSessionBox(
                          'Sáng',
                          '07:00 - 11:00',
                          Icons.wb_twilight_rounded,
                          const Color(0xFFFFA726),
                        ),
                        const SizedBox(height: 10),
                        _buildSessionBox(
                          'Chiều',
                          '13:00 - 17:00',
                          Icons.wb_sunny_rounded,
                          const Color(0xFF2589D8),
                        ),
                        const SizedBox(height: 10),
                        _buildSessionBox(
                          'Tối',
                          '18:00 - 22:00',
                          Icons.nights_stay_rounded,
                          const Color(0xFF8B72D9),
                        ),
                        const SizedBox(height: 18),
                        _buildSelectionSummary(),
                      ],
                    ),
                  ),
                ),
                _buildSaveBar(),
              ],
            ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -18,
            child: Icon(
              Icons.calendar_month_rounded,
              size: 110,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'THỜI GIAN CỦA BẠN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Sẵn sàng cho\ncơ hội mới?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Cập nhật lịch rảnh để doanh nghiệp '
                'dễ dàng tìm được khung giờ phù hợp với bạn.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.88),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildHeroStat(
                    Icons.calendar_today_rounded,
                    '$_selectedDayCount',
                    'Ngày đã chọn',
                  ),
                  const SizedBox(width: 22),
                  _buildHeroStat(
                    Icons.access_time_rounded,
                    '$_selectedSessionCount',
                    'Ca đã chọn',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primaryColor, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EFF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17365D).withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _monthButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  _monthName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _monthButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: day == 'CN'
                              ? const Color(0xFFE57373)
                              : mutedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildMonthCalendarGrid(),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFEDF1F5)),
          const SizedBox(height: 13),
          Row(
            children: [
              _buildCalendarLegend(
                color: primaryColor,
                label: 'Đang chọn',
              ),
              const SizedBox(width: 18),
              _buildCalendarLegend(
                color: primaryColor.withOpacity(0.17),
                label: 'Đã có lịch',
                borderColor: primaryColor.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: primaryColor, size: 25),
        ),
      ),
    );
  }

  Widget _buildCalendarLegend({
    required Color color,
    required String label,
    Color? borderColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: mutedColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    final firstDay = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );

    final weekdayOffset = firstDay.weekday - 1;
    final totalCells = weekdayOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: List.generate(7, (column) {
              final cellIndex = row * 7 + column;
              final day = cellIndex - weekdayOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(
                  child: SizedBox(height: 43),
                );
              }

              final currentDate = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );

              final normalizedCurrent = _normalizeDate(currentDate);
              final normalizedSelected = _normalizeDate(_selectedDate);

              final isSelected = normalizedCurrent == normalizedSelected;
              final hasData =
                  _selectedSchedules[normalizedCurrent]?.isNotEmpty ?? false;

              final isSunday = column == 6;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedDate = currentDate);
                    },
                    borderRadius: BorderRadius.circular(13),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 43,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : hasData
                                ? primaryColor.withOpacity(0.10)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : hasData
                                  ? primaryColor.withOpacity(0.3)
                                  : Colors.transparent,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : hasData
                                        ? primaryColor
                                        : isSunday
                                            ? const Color(0xFFE57373)
                                            : textColor,
                                fontSize: 13,
                                fontWeight: isSelected || hasData
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (hasData && !isSelected)
                            Positioned(
                              bottom: 5,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSessionBox(
    String title,
    String time,
    IconData icon,
    Color accent,
  ) {
    final normalizedSelected = _normalizeDate(_selectedDate);
    final isSelected =
        _selectedSchedules[normalizedSelected]?.contains(title) ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSession(title),
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : const Color(0xFFE5ECF3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primaryColor.withOpacity(0.13)
                    : const Color(0xFF17365D).withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : accent.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ca $title',
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      time,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.78)
                            : mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFD5DEE8),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: primaryColor,
                        size: 18,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7EAF5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Chọn ngày trên lịch, sau đó chọn các ca bạn có thể làm. '
              'Nhấn “Lưu lịch rảnh” để cập nhật thông tin của bạn.',
              style: TextStyle(
                color: Color(0xFF426579),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEAF0F5)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17365D).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 7),
                Text(
                  '$_selectedDayCount ngày • $_selectedSessionCount ca đã chọn',
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 9),
                          Text(
                            'LƯU LỊCH RẢNH',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
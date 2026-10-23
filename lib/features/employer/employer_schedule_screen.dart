import 'package:flutter/material.dart';

class EmployerScheduleScreen extends StatefulWidget {
  const EmployerScheduleScreen({super.key});

  @override
  State<EmployerScheduleScreen> createState() => _EmployerScheduleScreenState();
}

class _EmployerScheduleScreenState extends State<EmployerScheduleScreen> {
  final Color primaryColor = const Color(0xFF00A896); 
  final Color successColor = const Color(0xFF10B981);
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  
  final Gradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF00A896), Color(0xFF43C6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  final Map<DateTime, Set<int>> _schedule = {};

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  void _onDateTapped(DateTime date) {
    setState(() {
      _selectedDate = _normalizeDate(date);
      if (_schedule[_selectedDate] == null) {
        _schedule[_selectedDate!] = {};
      }
    });
  }

  void _toggleShift(int shiftIndex) {
    if (_selectedDate == null) return;
    setState(() {
      if (_schedule[_selectedDate!]!.contains(shiftIndex)) {
        _schedule[_selectedDate!]!.remove(shiftIndex);
      } else {
        _schedule[_selectedDate!]!.add(shiftIndex);
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.07), blurRadius: 30, offset: const Offset(0, 14))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBackButton(),
                            const SizedBox(height: 20),
                            Text('Yêu cầu Lịch làm việc', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
                            const SizedBox(height: 8),
                            Text('Chọn các ngày và ca làm việc bắt buộc ứng viên phải đáp ứng cho vị trí này.', style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.5)),
                            const SizedBox(height: 28),
                            _buildCalendarHeader(),
                            const SizedBox(height: 20),
                            _buildWeekdaysBar(),
                            const SizedBox(height: 14),
                            _buildCalendarMatrix(),
                          ],
                        ),
                      ),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
                        child: _selectedDate != null ? _buildSessionSection() : _buildEmptySession(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: textDark),
            const SizedBox(width: 8),
            Text('Quay lại', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text('Tháng ${_focusedMonth.month.toString().padLeft(2, '0')}, ${_focusedMonth.year}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark)),
          ],
        ),
        Row(
          children: [
            _buildArrowButton(Icons.chevron_left_rounded, () => _changeMonth(-1)),
            const SizedBox(width: 8),
            _buildArrowButton(Icons.chevron_right_rounded, () => _changeMonth(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: textDark)),
    );
  }

  Widget _buildWeekdaysBar() {
    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: weekdays.map((w) => SizedBox(width: 40, child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF94A3B8))))).toList());
  }

  Widget _buildCalendarMatrix() {
    final int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final int firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + (firstWeekday - 1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.1),
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) return const SizedBox(); 
        int day = index - (firstWeekday - 1) + 1;
        DateTime currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        bool isSelected = _selectedDate == currentDate;
        bool hasSchedule = _schedule[currentDate] != null && _schedule[currentDate]!.isNotEmpty;

        return GestureDetector(
          onTap: () => _onDateTapped(currentDate),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected ? primaryGradient : null, color: isSelected ? null : const Color(0xFFF8FAFC),
              border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0), width: 1.2), borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))] : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(day.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isSelected ? Colors.white : const Color(0xFF334155))),
                if (hasSchedule) Positioned(bottom: 6, child: Container(width: 5, height: 5, decoration: BoxDecoration(color: isSelected ? Colors.white : successColor, shape: BoxShape.circle)))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14), border: Border(left: BorderSide(color: primaryColor, width: 4))),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: primaryColor, size: 18),
              const SizedBox(width: 10),
              Text('Yêu cầu ngày: ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSessionCard(0, 'Buổi Sáng', 'Từ 07:00 đến 11:30', Icons.wb_twilight_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
        const SizedBox(height: 12),
        _buildSessionCard(1, 'Buổi Chiều', 'Từ 13:00 đến 17:00', Icons.wb_sunny_rounded, const Color(0xFFFFEDD5), const Color(0xFFEA580C)),
        const SizedBox(height: 12),
        _buildSessionCard(2, 'Buổi Tối', 'Từ 17:30 đến 22:00', Icons.nightlight_round_rounded, const Color(0xFFE0E7FF), const Color(0xFF4F46E5)),
        
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('🚀 Đã gửi yêu cầu kết nối! Hệ thống đang tìm ứng viên.'), backgroundColor: successColor, behavior: SnackBarBehavior.floating));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('GỬI YÊU CẦU KẾT NỐI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.1)),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmptySession() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(children: [
        Icon(Icons.touch_app_rounded, size: 56, color: Colors.blueGrey.shade300),
        const SizedBox(height: 14),
        Text('Chưa chọn ngày', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark)),
        const SizedBox(height: 6),
        Text('Hãy chọn một ngày trên lịch để thiết lập ca làm việc', style: TextStyle(color: textMuted, fontSize: 13.5)),
      ]),
    );
  }

  Widget _buildSessionCard(int shiftIndex, String title, String time, IconData icon, Color iconBgColor, Color iconColor) {
    bool isSelected = _schedule[_selectedDate!]!.contains(shiftIndex);
    return GestureDetector(
      onTap: () => _toggleShift(shiftIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: isSelected ? successColor : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1.2), borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected ? [BoxShadow(color: successColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: textDark)), const SizedBox(height: 3), Text(time, style: TextStyle(color: textMuted, fontSize: 12.5, fontWeight: FontWeight.w600))])),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200), width: 24, height: 24,
              decoration: BoxDecoration(color: isSelected ? successColor : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: isSelected ? successColor : const Color(0xFFCBD5E1), width: 2)),
              child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            )
          ],
        ),
      ),
    );
  }
}
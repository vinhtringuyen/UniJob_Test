import 'package:flutter/material.dart';
import 'employer_jobs_screen.dart';
import 'employer_applications_screen.dart';
import 'employer_profile_screen.dart';

class EmployerMainScreen extends StatefulWidget {
  const EmployerMainScreen({super.key});

  @override
  State<EmployerMainScreen> createState() => _EmployerMainScreenState();
}

class _EmployerMainScreenState extends State<EmployerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployerJobsScreen(),
    const EmployerApplicationsScreen(),
    const EmployerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00A896);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.blueGrey.shade300,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              label: 'Tin tuyển dụng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Ứng viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}
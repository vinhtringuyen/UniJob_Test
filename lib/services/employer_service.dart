import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm tìm kiếm ứng viên khớp với Map/Object requirement
  Future<List<Map<String, dynamic>>> searchCandidatesByRequirement(
    dynamic requirement,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      List<Map<String, dynamic>> matchedList = [];

      // Trích xuất thông tin từ requirement (chấp nhận Map hoặc Object)
      Map<String, dynamic> reqMap = requirement is Map<String, dynamic>
          ? requirement
          : {
              'title': requirement.title ?? '',
              'skills': requirement.skills ?? '',
              'gender': requirement.gender ?? 'Tất cả',
              'level': requirement.level ?? 'Tất cả',
              'major': requirement.major ?? 'Tất cả',
              'scheduleData': requirement.scheduleData ?? {},
            };

      String skills = (reqMap['skills'] ?? '').toString();
      String gender = (reqMap['gender'] ?? 'Tất cả').toString();
      String level = (reqMap['level'] ?? 'Tất cả').toString();
      String major = (reqMap['major'] ?? 'Tất cả').toString();
      var scheduleData = reqMap['scheduleData'];

      List<String> skillKeywords = skills
          .toLowerCase()
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String name = '${data['lastName'] ?? ''} ${data['firstName'] ?? ''}'.trim();
        if (name.isEmpty) name = data['name'] ?? 'Sinh viên';

        String studentSkills = (data['skills'] ?? '').toString().toLowerCase();
        String studentGender = (data['gender'] ?? 'Chưa rõ').toString();
        String studentLevel = (data['level'] ?? 'Chưa rõ').toString();
        String studentMajor = (data['major'] ?? 'Chưa rõ').toString();
        Map<String, dynamic> studentSchedules = data['availableSchedules'] ?? {};

        int totalCriteria = 0;
        int matchedCriteria = 0;

        // 1. Khớp Lịch trình
        if (scheduleData != null) {
          Map scheduleMap = scheduleData is Map ? scheduleData : {};
          scheduleMap.forEach((dateKey, shifts) {
            Iterable requiredShifts = shifts is Iterable ? shifts : [];
            for (var shift in requiredShifts) {
              totalCriteria++;
              if (studentSchedules.containsKey(dateKey)) {
                List<dynamic> studentShifts = studentSchedules[dateKey] ?? [];
                if (studentShifts.contains(shift)) {
                  matchedCriteria++;
                }
              }
            }
          });
        }

        // 2. Khớp Kỹ năng
        if (skillKeywords.isNotEmpty) {
          for (String skill in skillKeywords) {
            totalCriteria++;
            if (studentSkills.contains(skill)) {
              matchedCriteria++;
            }
          }
        }

        // 3. Khớp Giới tính
        if (gender != 'Tất cả') {
          totalCriteria++;
          if (studentGender.toLowerCase() == gender.toLowerCase()) {
            matchedCriteria++;
          }
        }

        // 4. Khớp Trình độ / Năm học
        if (level != 'Tất cả') {
          totalCriteria++;
          if (studentLevel.toLowerCase() == level.toLowerCase()) {
            matchedCriteria++;
          }
        }

        // 5. Khớp Ngành học
        if (major != 'Tất cả') {
          totalCriteria++;
          if (studentMajor.toLowerCase().contains(major.toLowerCase())) {
            matchedCriteria++;
          }
        }

        int matchPercentage = totalCriteria == 0
            ? 50
            : ((matchedCriteria / totalCriteria) * 100).round();

        if (matchPercentage > 100) matchPercentage = 100;

        matchedList.add({
          'id': doc.id,
          'name': name,
          'gender': studentGender,
          'level': studentLevel,
          'major': studentMajor,
          'skills': data['skills'] ?? 'Chưa cập nhật kỹ năng',
          'phone': data['phone'] ?? 'Chưa có SĐT',
          'matchPercentage': matchPercentage,
        });
      }

      matchedList.sort((a, b) => (b['matchPercentage'] as int).compareTo(a['matchPercentage'] as int));

      return matchedList;
    } catch (e) {
      rethrow;
    }
  }
}
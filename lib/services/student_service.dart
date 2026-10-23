import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lưu hoặc cập nhật hồ sơ CV của sinh viên lên Firestore
  Future<bool> saveStudentCV({
    required String fullName,
    required String dob,
    required String gender,
    required String ethnicity,
    required String location,
    required String email,
    required String phone,
    required String education,
    required String major,
    required String skills,
    required String objective,
    required String hobbies,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('students').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'dob': dob,
        'gender': gender,
        'ethnicity': ethnicity,
        'location': location,
        'email': email,
        'phone': phone,
        'education': education,
        'major': major,
        'skills': skills,
        'objective': objective,
        'hobbies': hobbies,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Dùng merge: true để không ghi đè mất các trường dữ liệu khác nếu có

      return true;
    } catch (e) {
      print('Lỗi khi lưu CV: $e');
      return false;
    }
  }

  // --- HÀM ỨNG TUYỂN CÔNG VIỆC CHO SINH VIÊN ---
  Future<bool> applyForJob({
    required String jobId,
    required String jobTitle,
    required String companyName,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Lấy thông tin CV hiện tại của sinh viên từ Firestore
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(user.uid).get();
      if (!studentDoc.exists) return false;
      var studentData = studentDoc.data() as Map<String, dynamic>;

      // Lưu hồ sơ ứng tuyển vào collection 'applications'
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'studentUid': user.uid,
        'studentName': studentData['fullName'] ?? 'Chưa cập nhật',
        'studentEmail': studentData['email'] ?? user.email ?? '',
        'studentPhone': studentData['phone'] ?? '',
        'major': studentData['major'] ?? '',
        'skills': studentData['skills'] ?? '',
        'status': 'Pending', // Trạng thái chờ doanh nghiệp duyệt
        'appliedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Lỗi khi ứng tuyển: $e');
      return false;
    }
  }
}
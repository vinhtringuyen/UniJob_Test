import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // --- HÀM DÀNH CHO SINH VIÊN ĐĂNG KÝ ---
  Future<String?> registerStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String phoneNumber,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$lastName $firstName',
          'username': username,
          'phoneNumber': phoneNumber,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Lỗi không xác định: ${e.toString()}';
    }
  }

  // --- HÀM DÀNH CHO DOANH NGHIỆP ĐĂNG KÝ ---
  Future<String?> registerEmployer({
    required String email,
    required String password,
    required String companyName,
    required String contactName,
    required String taxCode,
    required String phoneNumber,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'companyName': companyName,
          'contactName': contactName,
          'taxCode': taxCode,
          'phoneNumber': phoneNumber,
          'role': 'employer',
          'isApproved': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Lỗi không xác định: ${e.toString()}';
    }
  }

  // --- HÀM ĐĂNG NHẬP ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        return {
          'success': true,
          'userData': userDoc.data() as Map<String, dynamic>,
        };
      } else {
        return {
          'success': false,
          'message': 'Không tìm thấy dữ liệu người dùng trên hệ thống!',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: ${e.toString()}',
      };
    }
  }

  // --- HÀM QUÊN MẬT KHẨU (GỬI EMAIL KÍCH HOẠT LẠI) ---
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Gửi thành công
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại!';
    }
  }

  // --- ĐĂNG XUẤT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- HÀM BẮT LỖI FIREBASE TIẾNG VIỆT ---
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'invalid-email':
        return 'Địa chỉ Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng thử lại!';
      case 'user-not-found':
        return 'Tài khoản Email không tồn tại trên hệ thống.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'user-disabled':
        return 'Tài khoản này đã bị khóa.';
      default:
        return e.message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại!';
    }
  }
}
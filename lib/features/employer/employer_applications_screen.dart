import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployerApplicationsScreen extends StatelessWidget {
  const EmployerApplicationsScreen({super.key});

  void _updateStatus(BuildContext context, String appId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('applications').doc(appId).update({
        'status': newStatus,
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật trạng thái đơn thành: $newStatus'),
          backgroundColor: newStatus == 'Accepted' ? Colors.green.shade600 : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật thất bại, vui lòng thử lại!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF176B87);
    const Color bgColor = Color(0xFFF4F7FB);
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text('Vui lòng đăng nhập doanh nghiệp.')),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Quản Lý Đơn Ứng Tuyển', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('applications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, size: 64, color: Colors.blueGrey.shade300),
                  const SizedBox(height: 16),
                  Text('Chưa có sinh viên nào ứng tuyển.', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          var appDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: appDocs.length,
            itemBuilder: (context, index) {
              var docId = appDocs[index].id;
              var data = appDocs[index].data() as Map<String, dynamic>;

              String studentName = data['studentName'] ?? 'Không rõ tên';
              String jobTitle = data['jobTitle'] ?? 'Công việc';
              String major = data['major'] ?? 'Chưa cập nhật';
              String skills = data['skills'] ?? 'Không có';
              String phone = data['studentPhone'] ?? 'Chưa có SĐT';
              String status = data['status'] ?? 'Pending';

              Color statusColor = status == 'Approved' || status == 'Accepted'
                  ? Colors.green.shade600
                  : status == 'Rejected'
                      ? Colors.redAccent
                      : Colors.orange.shade700;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            studentName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Ứng tuyển: $jobTitle', style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.book_rounded, 'Chuyên ngành: $major'),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.star_outline_rounded, 'Kỹ năng: $skills'),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.phone_outlined, 'SĐT: $phone'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () => _updateStatus(context, docId, 'Rejected'),
                          child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _updateStatus(context, docId, 'Accepted'),
                          child: const Text('Chấp nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.5, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
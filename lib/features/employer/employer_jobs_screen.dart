import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  void _showAddJobDialog() {
    const Color primaryColor = Color(0xFF00A896);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Đăng Việc Làm Mới', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tiêu đề công việc', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('VD: Lập trình viên Flutter'),
              ),
              const SizedBox(height: 14),
              const Text('Địa điểm', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: _inputDecoration('VD: Trà Vinh'),
              ),
              const SizedBox(height: 14),
              const Text('Mức lương', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _salaryController,
                decoration: _inputDecoration('VD: 7 - 10 triệu'),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.blueGrey.shade500, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (_titleController.text.isNotEmpty && currentUser != null) {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .get();
                var userData = userDoc.data() as Map<String, dynamic>?;
                String companyName = userData?['companyName'] ?? 'Doanh nghiệp';

                await FirebaseFirestore.instance.collection('jobs').add({
                  'employerUid': currentUser!.uid,
                  'companyName': companyName,
                  'title': _titleController.text.trim(),
                  'location': _locationController.text.trim(),
                  'salary': _salaryController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                _titleController.clear();
                _locationController.clear();
                _salaryController.clear();

                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Đăng Bài', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00A896), width: 1.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00A896);
    const Color bgColor = Color(0xFFF4F7FB);

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text('Vui lòng đăng nhập tài khoản doanh nghiệp.')),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Quản Lý Tin Tuyển Dụng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('employerUid', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline_rounded, size: 70, color: Colors.blueGrey.shade300),
                  const SizedBox(height: 14),
                  Text('Bạn chưa đăng tin tuyển dụng nào.', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          var jobDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobDocs.length,
            itemBuilder: (context, index) {
              var job = jobDocs[index].data() as Map<String, dynamic>;
              String jobId = jobDocs[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  title: Text(
                    job['title'] ?? 'Tiêu đề',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey.shade400),
                            const SizedBox(width: 4),
                            Text('${job['location'] ?? 'Trà Vinh'}', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.payments_outlined, size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text('Mức lương: ${job['salary'] ?? 'Thỏa thuận'}', style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _showAddJobDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
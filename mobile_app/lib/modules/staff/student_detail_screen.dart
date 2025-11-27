//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'staff_controller.dart';

// ⚠️ Change: StatelessWidget থেকে StatefulWidget করা হলো
class StudentDetailScreen extends StatefulWidget {
  final Map student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StaffController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // ✅ Fix: পেজ লোড হওয়ার পর ডাটা কল হবে
    // WidgetsBinding ব্যবহার করা হলো যাতে বিল্ড শেষ হওয়ার পর ফাংশন কল হয়
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStudentResults(widget.student['email']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student['name']), // widget.student ব্যবহার করতে হবে
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 👤 Header Info Card
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.indigo.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo,
                  // নামের প্রথম অক্ষর দেখানো
                  child: Text(
                    widget.student['name'][0].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.student['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("ID: ${widget.student['student_id'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey)),
                    Text("Session: ${widget.student['session'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Text("Academic Results", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),

          // 📋 Result List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.selectedStudentResults.isEmpty) {
                return const Center(child: Text("No results found for this student."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.selectedStudentResults.length,
                itemBuilder: (context, index) {
                  var result = controller.selectedStudentResults[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[50],
                        child: Text(
                            result['grade'],
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                        ),
                      ),
                      title: Text(result['course_code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Semester: ${result['semester']} | GPA: ${result['gpa']}"),

                      // 🛠️ Action Buttons
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => controller.showEditResultDialog(result, widget.student['email']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteResultAPI(result['id'], widget.student['email']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
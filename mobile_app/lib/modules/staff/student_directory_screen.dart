//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\student_directory_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gstu_cse/modules/staff/student_detail_screen.dart';
import 'staff_controller.dart';
// import 'student_detail_screen.dart'; // এটা আমরা পরের ধাপে বানাবো

class StudentDirectoryScreen extends StatelessWidget {
  final StaffController controller = Get.put(StaffController());

  StudentDirectoryScreen({super.key}) {
    // পেজে ঢুকেই লিস্ট লোড করবে
    controller.fetchAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Student Directory"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 1. Search Bar Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo, // অ্যাপবারের সাথে মিল রেখে কালার
            child: TextField(
              onChanged: (value) => controller.filterStudents(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by Name or ID...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          // 📋 2. Student List Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredStudents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text("No student found!", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.filteredStudents.length,
                itemBuilder: (context, index) {
                  var student = controller.filteredStudents[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // 👤 Avatar ( নামের প্রথম অক্ষর)
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        backgroundImage: student['avatar_url'] != null
                            ? NetworkImage(student['avatar_url'])
                            : null,
                        child: student['avatar_url'] == null
                            ? Text(
                          student['name'][0].toString().toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 20),
                        )
                            : null,
                      ),

                      // 📝 Name & ID
                      title: Text(
                        student['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("ID: ${student['student_id'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(student['email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),

                      // ➡️ Arrow Icon
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

                      // 👉 Click Action (Next Step e kaj korbo)
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Get.to(() => StudentDetailScreen(student: student));
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
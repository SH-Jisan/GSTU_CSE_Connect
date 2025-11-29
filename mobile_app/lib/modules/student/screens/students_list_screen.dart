import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/public_student_controller.dart';
// স্টুডেন্ট ডিটেইলস পেজটা রিইউজ করব (যেটা স্টাফ ফোল্ডারে আছে)
import '../../staff/screens/student_detail_screen.dart';

class StudentsListScreen extends StatelessWidget {
  final PublicStudentController controller = Get.put(PublicStudentController());

  StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Student Directory"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: TextField(
              onChanged: (val) => controller.filterList(val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Name or ID...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),

          // 📋 Grouped List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              var grouped = controller.groupedStudents;
              var groupKeys = grouped.keys.toList();

              // গ্রাজুয়েটেড বা সিনিয়রিটি অনুযায়ী সর্ট করার লজিক এখানে চাইলে দেওয়া যায়
              // আপাতত ডিফল্ট অর্ডারে দেখাচ্ছি

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: groupKeys.length,
                itemBuilder: (context, index) {
                  String groupName = groupKeys[index];
                  List students = grouped[groupName]!;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ExpansionTile(
                      // 📂 Header: Semester Name
                      title: Text(
                          groupName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                      ),
                      leading: Icon(
                          groupName.contains("Graduated") ? Icons.school : Icons.folder,
                          color: groupName.contains("Graduated") ? Colors.orange : Colors.indigo
                      ),
                      children: students.map((student) {
                        bool isCR = student['is_cr'] == true; // CR Check

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            backgroundImage: (student['avatar_url'] != null)
                                ? NetworkImage(student['avatar_url'])
                                : null,
                            child: (student['avatar_url'] == null)
                                ? Text(student['name'][0].toString().toUpperCase())
                                : null,
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    student['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  )
                              ),
                              // 🌟 CR Badge
                              if (isCR)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                  child: const Text("CR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                )
                            ],
                          ),
                          subtitle: Text("ID: ${student['student_id'] ?? 'N/A'}"),
                          onTap: () {
                            // ডিটেইলস পেজে নিয়ে যাওয়া
                            Get.to(() => StudentDetailScreen(student: student));
                          },
                        );
                      }).toList(),
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/staff_result_controller.dart';

class StudentDetailScreen extends StatefulWidget {
  final Map student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StaffResultController controller = Get.put(StaffResultController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStudentResults(widget.student['email']);
    });
  }

  @override
  Widget build(BuildContext context) {
    var student = widget.student;
    bool isGraduated = student['current_year'] == 'Graduated';
    return Scaffold(
      backgroundColor: Colors.grey[50], // হালকা ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🎨 1. Modern Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 10),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with Border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: (student['avatar_url'] != null && student['avatar_url'].toString().isNotEmpty)
                          ? NetworkImage(student['avatar_url'])
                          : null,
                      child: (student['avatar_url'] == null || student['avatar_url'].toString().isEmpty)
                          ? Text(
                        student['name'][0].toString().toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.indigo),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Name & ID
                  Text(
                    student['name'],
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "ID: ${student['student_id'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      student['email'],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎓 2. Academic Info Cards (Session, Year, Semester)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: isGraduated
              // 🏆 Graduated View
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10)]
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 50, color: Colors.white),
                    const SizedBox(height: 10),
                    Text("Graduated / Alumni", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text("Batch Session: ${student['session'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              )
              // 📚 Regular Student View
                  : Row(
                children: [
                  _buildInfoCard(Icons.calendar_today, "Session", student['session'] ?? "N/A", Colors.orange),
                  const SizedBox(width: 10),
                  _buildInfoCard(Icons.school, "Year", student['current_year'] ?? "N/A", Colors.blue),
                  const SizedBox(width: 10),
                  _buildInfoCard(Icons.book, "Semester", student['current_semester'] ?? "N/A", Colors.teal),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 📊 3. Results Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.indigo),
                  const SizedBox(width: 10),
                  Text("Academic Results", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider()),

            // 📋 4. Result List
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.selectedStudentResults.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_late, size: 50, color: Colors.grey[300]),
                        const Text("No results uploaded yet.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true, // স্ক্রল ভিউয়ের ভেতরে লিস্টভিউ তাই এটা জরুরি
                physics: const NeverScrollableScrollPhysics(), // বাইরের স্ক্রল কাজ করবে
                itemCount: controller.selectedStudentResults.length,
                itemBuilder: (context, index) {
                  var result = controller.selectedStudentResults[index];
                  bool isGood = double.tryParse(result['gpa'].toString())! >= 3.0;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isGood ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                            result['grade'],
                            style: TextStyle(
                                color: isGood ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )
                        ),
                      ),
                      title: Text(result['course_code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("GPA: ${result['gpa']}"),

                      // Action Buttons
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                            onPressed: () => controller.showEditResultDialog(result, widget.student['email']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: () => controller.deleteResultAPI(result['id'], widget.student['email']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ✨ Helper Widget for Info Cards
  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
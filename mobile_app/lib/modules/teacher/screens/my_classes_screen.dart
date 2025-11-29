import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/teacher_controller.dart';

class MyClassesScreen extends StatelessWidget {
  final TeacherController controller = Get.put(TeacherController());

  MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String tomorrowDate = DateFormat('EEEE, d MMM').format(DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("My Assigned Classes"), backgroundColor: Colors.teal),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.allClasses.isEmpty) return const Center(child: Text("No classes assigned to you."));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌅 Section 1: Tomorrow's Classes
              Container(
                padding: const EdgeInsets.only(left: 5, bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.wb_twilight, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                        "Tomorrow ($tomorrowDate)",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                  ],
                ),
              ),

              if (controller.tomorrowClasses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text("No classes scheduled for tomorrow! 🎉", style: TextStyle(color: Colors.grey))),
                )
              else
                ...controller.tomorrowClasses.map((routine) => _buildClassCard(routine)).toList(),

              const SizedBox(height: 30),

              // 📚 Section 2: Other Classes
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 10),
                child: Text(
                    "All Other Classes",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)
                ),
              ),

              ...controller.groupedClasses.keys.map((semester) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ExpansionTile(
                    title: Text(semester, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    leading: const Icon(Icons.folder_shared, color: Colors.teal),
                    children: (controller.groupedClasses[semester] as List).map((routine) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: _buildClassCard(routine),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ✨ Class Card Widget (Fixed Overflow using Custom Row)
  Widget _buildClassCard(var routine) {
    bool isCancelled = routine['is_cancelled'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12), // প্যাডিং ব্যবহার করলাম
      decoration: BoxDecoration(
        color: isCancelled ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCancelled ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ⏰ 1. Time Box (Left)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCancelled ? Colors.redAccent : Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  routine['start_time'].toString().substring(0, 5),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Text("TO", style: TextStyle(color: Colors.white70, fontSize: 8)),
                Text(
                  routine['end_time'].toString().substring(0, 5),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // 📝 2. Info Section (Middle - Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine['course_title'] ?? "No Title",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                      color: isCancelled ? Colors.red : Colors.black87
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                    "${routine['day']} • ${routine['course_code']}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                ),
                Text(
                    "Room: ${routine['room_no']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                ),
              ],
            ),
          ),

          // 🎚️ 3. Toggle Switch (Right)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // সুইচটি একটু ছোট করার জন্য Transform ব্যবহার করা হলো
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: !isCancelled,
                  activeColor: Colors.teal,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red[100],
                  onChanged: (val) {
                    Get.find<TeacherController>().toggleClassStatus(routine['id']);
                  },
                ),
              ),
              Text(
                isCancelled ? "Cancelled" : "Active",
                style: TextStyle(
                    fontSize: 10,
                    color: isCancelled ? Colors.red : Colors.teal,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
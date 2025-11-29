import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routine_controller.dart';

class RoutineScreen extends StatelessWidget {
  final RoutineController controller = Get.put(RoutineController());

  RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.routineList.isEmpty) {
          return const Center(child: Text("No classes scheduled yet!"));
        }

        // 📂 গ্রুপিং ডাটা আনা
        var grouped = controller.groupedRoutines;
        var semesters = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: semesters.length,
          itemBuilder: (context, index) {
            String semester = semesters[index];
            List routines = grouped[semester]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ExpansionTile(
                // 📂 সেমিস্টার হেডার
                title: Text(
                    semester,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16)
                ),
                leading: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                childrenPadding: const EdgeInsets.all(10),

                // 📝 ওই সেমিস্টারের সব ক্লাসের লিস্ট
                children: routines.map((routine) => _buildRoutineCard(routine)).toList(),
              ),
            );
          },
        );
      }),
    );
  }

  // ✨ একটি ক্লাসের কার্ড ডিজাইন (আগের মতোই, একটু ছোট করা হয়েছে লিস্টের জন্য)
  Widget _buildRoutineCard(dynamic routine) {
    bool isCancelled = routine['is_cancelled'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isCancelled ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.2)
        ),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          // ⏰ বাম পাশের সময়
          Column(
            children: [
              Text(
                  routine['start_time'].toString().substring(0, 5),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
              ),
              Container(height: 30, width: 2, color: isCancelled ? Colors.red[200] : Colors.blue[100]),
              Text(
                  routine['end_time'].toString().substring(0, 5),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
            ],
          ),
          const SizedBox(width: 15),

          // 📝 ডান পাশের ডিটেইলস
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Day Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCancelled ? Colors.red : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                          isCancelled ? "CANCELLED" : routine['day'],
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                    ),

                    // ❌ Teacher Cancel Button (যদি টিচার হয়)
                    Obx(() {
                      if (controller.userRole.value == 'teacher') {
                        return InkWell(
                          onTap: () => controller.toggleClassStatus(routine['id']),
                          child: Icon(
                            isCancelled ? Icons.restore : Icons.cancel,
                            color: isCancelled ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                  ],
                ),
                const SizedBox(height: 5),

                Text(
                  routine['course_title'] ?? "No Title",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                      color: isCancelled ? Colors.red : Colors.black87
                  ),
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(Icons.room, size: 14, color: isCancelled ? Colors.red[300] : Colors.grey),
                    const SizedBox(width: 4),
                    Text("Room ${routine['room_no']}", style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 10),
                    Icon(Icons.person, size: 14, color: isCancelled ? Colors.red[300] : Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(
                            routine['teacher_name'] ?? "Unknown",
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
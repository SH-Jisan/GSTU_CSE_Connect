import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gstu_cse/modules/teacher/screens/attendance_screen.dart';
import 'my_classes_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text("Teacher Control Panel", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 20),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuCard(
                  icon: Icons.calendar_today,
                  title: "My Assigned\nClasses",
                  color: Colors.teal,
                  onTap: () => Get.to(() => MyClassesScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.fact_check,
                  title: "Take\nAttendance",
                  color: Colors.green,
                  onTap: () => Get.to(() => AttendanceScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.upload_file,
                  title: "Upload\nMaterials",
                  color: Colors.orange,
                  onTap: () {
                    // আমাদের আগের Course Material Screen এ নিয়ে যেতে পারি
                    // অথবা ফিউচার ফিচারের জন্য রেখে দিতে পারি
                    Get.snackbar("Info", "Go to Course Materials from Sidebar to upload files.");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
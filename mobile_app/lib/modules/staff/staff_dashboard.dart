//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\staff\staff_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gstu_cse/modules/staff/student_directory_screen.dart';
import 'pending_requests_screen.dart';
import '../notice/add_notice_screen.dart';
import 'update_routine_screen.dart';
import 'upload_result_screen.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold আর AppBar সরিয়ে দিয়েছি
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
              "Admin Control Panel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuCard(
                  icon: Icons.verified_user,
                  title: "Approve\nSignups",
                  color: Colors.purple,
                  onTap: () => Get.to(() => PendingRequestsScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.upload_file,
                  title: "Update\nRoutine",
                  color: Colors.orange,
                  onTap: () => Get.to(() => UpdateRoutineScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.grade,
                  title: "Upload\nResult",
                  color: Colors.teal,
                  onTap: () => Get.to(() => UploadResultScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.campaign,
                  title: "Post\nNotice",
                  color: Colors.blue,
                  onTap: () => Get.to(() => AddNoticeScreen()),
                ),
                _buildMenuCard(
                  icon: Icons.people_alt,
                  title: "Student\nDirectory",
                  color: Colors.indigo,
                  onTap: (){
                    Get.to(() => StudentDirectoryScreen());
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
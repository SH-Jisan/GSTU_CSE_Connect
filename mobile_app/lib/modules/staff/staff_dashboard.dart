import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gstu_cse/modules/notice/add_notice_screen.dart';
import 'package:gstu_cse/modules/staff/update_routine_screen.dart';
import 'package:gstu_cse/modules/staff/upload_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import 'pending_requests_screen.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Office Staff Panel"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAll(() => LoginScreen());
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2, // ২ কলাম
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
              onTap: (){
                Get.to(() => UpdateRoutineScreen());
              }
            ),
            _buildMenuCard(
              icon: Icons.grade,
              title: "Upload\nResult",
              color: Colors.teal,
              onTap: (){
                Get.to(() => UploadResultScreen());
              },
            ),
            _buildMenuCard(
              icon: Icons.campaign,
              title: "Post\nNotice",
              color: Colors.blue,
              onTap: () {
                Get.to(() => AddNoticeScreen());
              },
            ),
          ],
        ),
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
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
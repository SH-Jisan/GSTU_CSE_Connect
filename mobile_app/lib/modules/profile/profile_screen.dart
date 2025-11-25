import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        var user = controller.userData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 📸 প্রোফাইল ছবি (Avatar)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: Text(
                    user['name'] != null ? user['name'][0].toUpperCase() : "U",
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // নাম এবং রোল
              Text(
                user['name'] ?? "User Name",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                user['email'] ?? "email@example.com",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Chip(
                label: Text(user['role']?.toUpperCase() ?? "STUDENT"),
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              // 📝 ইনফরমেশন কার্ড
              _buildInfoRow(Icons.badge, "Student ID", user['student_id'] ?? "N/A"),
              _buildInfoRow(Icons.calendar_today, "Session", user['session'] ?? "N/A"),
              if (user['role'] == 'teacher')
                _buildInfoRow(Icons.work, "Designation", user['designation'] ?? "N/A"),

              // CR হলে স্পেশাল ব্যাজ
              if (user['is_cr'] == true)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
                  child: Row(children: const [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("You are the Class Representative (CR)", style: TextStyle(color: Colors.orange))
                  ]),
                ),

              const SizedBox(height: 40),

              // 🚪 লগআউট বাটন
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.logout(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // ছোট হেল্পার উইজেট (একই কোড বারবার না লেখার জন্য)
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}
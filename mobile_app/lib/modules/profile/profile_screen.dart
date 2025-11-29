import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'profile_controller.dart';
import 'edit_profile_sheet.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        var user = controller.userData;

        bool isStudent = user['role'] == 'student';
        bool isCR = user['is_cr'] == true;
        bool isGraduated = user['current_year'] == 'Graduated';

        return SingleChildScrollView(
          child: Column(
            children: [
              // 🎨 1. Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: (user['avatar_url'] != null && user['avatar_url'].toString().isNotEmpty)
                                ? NetworkImage(user['avatar_url'])
                                : null,
                            child: (user['avatar_url'] == null || user['avatar_url'].toString().isEmpty)
                                ? Text(
                              user['name'] != null ? user['name'][0].toString().toUpperCase() : "U",
                              style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            )
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openEditSheet(user),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Name & Role
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user['name'] ?? "User Name",
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCR)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: const Text("CR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                          )
                      ],
                    ),

                    // Email
                    Text(
                      user['email'] ?? "",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    // 🆕 Phone Number Display
                    if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone, color: Colors.white70, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              user['phone'],
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // ID or Designation Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        isStudent ? "ID: ${user['student_id'] ?? 'N/A'}" : "${user['designation'] ?? 'Teacher'}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🎓 2. Academic Info Cards
              if (isStudent)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isGraduated
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
                        Text("Batch Session: ${user['session'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  )
                      : Row(
                    children: [
                      _buildInfoCard(Icons.calendar_month, "Session", user['session'] ?? "N/A", Colors.orange),
                      const SizedBox(width: 15),
                      _buildInfoCard(Icons.school, "Year", user['current_year'] ?? "N/A", Colors.purple),
                      const SizedBox(width: 15),
                      _buildInfoCard(Icons.class_, "Semester", user['current_semester'] ?? "N/A", Colors.teal),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // ⚙️ 3. Menu Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 15),

                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: "Edit Profile",
                      subtitle: "Change name, photo or bio",
                      onTap: () => _openEditSheet(user),
                    ),

                    _buildSettingsTile(
                      icon: Icons.notifications_active_outlined,
                      title: "Fix Notifications",
                      subtitle: "Tap if alerts are not working",
                      onTap: () async {
                        FirebaseMessaging messaging = FirebaseMessaging.instance;
                        NotificationSettings settings = await messaging.requestPermission();
                        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
                          await messaging.subscribeToTopic('notices');
                          Get.snackbar("Success", "Subscribed to alerts! ✅", backgroundColor: Colors.green, colorText: Colors.white);
                        } else {
                          Get.snackbar("Error", "Enable permissions in settings", backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                    ),

                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.logout(),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 🛠️ Helper Methods

  void _openEditSheet(Map user) {
    Get.bottomSheet(
      EditProfileSheet(
        currentName: user['name'] ?? "",
        currentDesig: user['designation'] ?? "",
        currentPhone: user['phone'] ?? "",
        // 🆕 Data pass kora hocche
        currentYear: user['current_year'],
        currentSemester: user['current_semester'],
        role: user['role'] ?? "student",
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
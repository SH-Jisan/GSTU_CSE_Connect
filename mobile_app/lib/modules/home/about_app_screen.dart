import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true, // হেডার ট্রান্সপারেন্ট করার জন্য
      appBar: AppBar(
        title: const Text("About App"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 1. Modern Header (Curved Background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: const Icon(Icons.school, size: 50, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "GSTU CSE Connect",
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    "Version 2.0.0 (Beta)",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    "A complete automation solution for the Department of CSE, GSTU.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // 🌟 2. Supervisor Section (Highlighted with Gradient)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Supervised By", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Icon(Icons.star_rounded, color: Colors.orange, size: 35),
                          ),
                        ),
                        title: const Text(
                          "Abu-Bakar Muhammad Abdullah", // স্যারের নাম এখানে দাও
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                        subtitle: const Text(
                          "Assistant Professor\nDept of CSE, GSTU",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 👨‍💻 3. Developer Info
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Developed By", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage("https://scontent.fdac31-2.fna.fbcdn.net/v/t39.30808-6/465843422_2226569951033605_6803246507096223161_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeHu6Tk_YqQrzpEv308ANKgjPUJo8OtSUIE9Qmjw61JQgR69tlU4xr3aFmGOkW0ncFOOKKOXKvrBD5rqgaL-n_8I&_nc_ohc=vptLGuyw2XEQ7kNvwEdQn6e&_nc_oc=Adm1Pvwwt-R25Yh7SupUept6erpILsGJGFfkBLm3riciuv-0oqtDMdICqMQn_Uvc8bc&_nc_zt=23&_nc_ht=scontent.fdac31-2.fna&_nc_gid=-IcCa1zut1bXkiv3wec6qQ&oh=00_Afj2eGjhIw9p5PkHzwTwmoaqQxVRggI3JsO1eOZixGEDaA&oe=6930E587"), // তোমার ছবি থাকলে এখানে লিংক দাও
                            radius: 35,
                          ),
                          const SizedBox(height: 12),
                          const Text("SH Jisan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Text("Computer Science & Engineering\nStudent ID: 22CSE029 | "
                              "Session: 2019-20", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 20),

                          // Contact Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(
                                  icon: Icons.email_outlined,
                                  color: Colors.redAccent,
                                  label: "Email",
                                  onTap: () => _launchUrl("shzisun123@gmail.com")
                              ),
                              const SizedBox(width: 15),
                              _socialButton(
                                  icon: Icons.code,
                                  color: Colors.black87,
                                  label: "GitHub",
                                  onTap: () => _launchUrl("https://github.com/SH-Jisan")
                              ),
                              const SizedBox(width: 15),
                              _socialButton(
                                  icon: Icons.link,
                                  color: Colors.blue,
                                  label: "LinkedIn",
                                  onTap: () => _launchUrl("https://linkedin.com/in/yourprofile")
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🛠️ 4. Tech Stack
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Tech Stack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip("Flutter", Colors.blue.shade600),
                      _buildTechChip("Node.js", Colors.green.shade600),
                      _buildTechChip("PostgreSQL", Colors.indigo.shade600),
                      _buildTechChip("Firebase", Colors.orange.shade700),
                      _buildTechChip("Cloudinary", Colors.purple.shade600),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 🐛 5. Report Bug Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl("mailto:shzisun123@gmail.com?subject=Bug Report - GSTU CSE Connect"),
                      icon: const Icon(Icons.bug_report_outlined, size: 20),
                      label: const Text("Report a Bug"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text("© 2025 Dept of CSE, GSTU", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _socialButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.1))
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
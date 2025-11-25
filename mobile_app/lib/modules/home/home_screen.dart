import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 ওয়েলকাম মেসেজ
            Obx(() => Text(
              "Hello, ${controller.userName.value} 👋",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            )),
            const Text("Here are the latest updates", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            const Text("📢 Notice Board", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // 📋 নোটিস লিস্ট (API থেকে আসবে)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.noticeList.isEmpty) {
                  return const Center(child: Text("No notices available."));
                }
                return ListView.builder(
                  itemCount: controller.noticeList.length,
                  itemBuilder: (context, index) {
                    var notice = controller.noticeList[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: const Icon(Icons.notifications, color: Colors.blueAccent),
                        ),
                        title: Text(notice['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notice['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(notice['category'] ?? "General", style: const TextStyle(fontSize: 10, color: Colors.deepOrange)),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
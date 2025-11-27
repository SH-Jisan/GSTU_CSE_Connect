//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\notice\add_notice_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../staff/controllers/staff_notice_controller.dart';

class AddNoticeScreen extends StatelessWidget {
  final StaffNoticeController controller = Get.put(StaffNoticeController()); // আগের কন্ট্রোলারই ব্যবহার করব

  AddNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post New Notice"), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notice Title", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: "e.g. Mid-term Exam Schedule",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "General", child: Text("General")),
                    DropdownMenuItem(value: "Exam", child: Text("Exam")),
                    DropdownMenuItem(value: "Holiday", child: Text("Holiday")),
                    DropdownMenuItem(value: "Scholarship", child: Text("Scholarship")),
                    DropdownMenuItem(value: "Urgent", child: Text("Urgent")),
                  ],
                  onChanged: (val) => controller.selectedCategory.value = val!,
                ),
              )),
            ),
            const SizedBox(height: 20),

            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: controller.descController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write details here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: () => controller.postNotice(),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Publish Notice", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              )
              ),
            )
          ],
        ),
      ),
    );
  }
}
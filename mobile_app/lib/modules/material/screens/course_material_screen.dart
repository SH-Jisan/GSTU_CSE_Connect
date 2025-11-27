import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // 📅 Date format er jonno import
import '../controllers/material_controller.dart';

class CourseMaterialScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const CourseMaterialScreen({super.key, required this.courseId, required this.courseName});

  @override
  State<CourseMaterialScreen> createState() => _CourseMaterialScreenState();
}

class _CourseMaterialScreenState extends State<CourseMaterialScreen> {
  final MaterialController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMaterials(widget.courseId);
    });
  }

  // 📅 Date Formatter Helper
  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date); // Ex: 28 Nov 2025, 10:30 AM
    } catch (e) {
      return "Date unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName), backgroundColor: Colors.teal),

      floatingActionButton: Obx(() {
        if (controller.userRole.value == 'teacher') {
          return FloatingActionButton.extended(
            onPressed: () => controller.pickAndUploadFile(widget.courseId),
            label: const Text("Upload File"),
            icon: const Icon(Icons.upload_file),
            backgroundColor: Colors.teal,
          );
        }
        return const SizedBox();
      }),

      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        if (controller.materialList.isEmpty) {
          return const Center(child: Text("No materials uploaded yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.materialList.length,
          itemBuilder: (context, index) {
            var file = controller.materialList[index];
            bool isPdf = file['file_type'].toString().contains('pdf');
            bool isPublic = file['is_public'] ?? true; // Default true
            bool isOwner = controller.currentUserId.value == file['uploaded_by'];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPdf ? Colors.red[50] : Colors.blue[50],
                      child: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.image,
                        color: isPdf ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(file['title'], style: const TextStyle(fontWeight: FontWeight.bold)),

                    // 📅 Subtitle e Date dekhano hocche
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("By: ${file['teacher_name'] ?? 'Unknown'}", style: const TextStyle(fontSize: 12)),
                        Text(
                            "Uploaded: ${formatDate(file['created_at'])}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey)
                        ),
                      ],
                    ),

                    trailing: (controller.userRole.value == 'teacher' && isOwner)
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🗑️ Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteMaterial(file['id'], widget.courseId),
                        ),
                      ],
                    )
                        : const Icon(Icons.download, color: Colors.grey),

                    onTap: () => controller.openMaterial(file['file_url']),
                  ),

                  // 🔒 Teacher der jonno Toggle Switch (Extra Row)
                  if (controller.userRole.value == 'teacher' && isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPublic ? "Status: Public (Visible to All)" : "Status: Private (Only Me)",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPublic ? Colors.green : Colors.red
                            ),
                          ),
                          Switch(
                            value: isPublic,
                            activeThumbColor: Colors.teal,
                            onChanged: (val) {
                              // API call kore status change
                              controller.toggleVisibility(file['id'], widget.courseId);
                            },
                          )
                        ],
                      ),
                    )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
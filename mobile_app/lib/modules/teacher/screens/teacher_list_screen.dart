//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\teacher\teacher_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';

class TeacherListScreen extends StatelessWidget {
  final TeacherController controller = Get.put(TeacherController());

  TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Members"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.teacherList.length,
          separatorBuilder: (c, i) => const Divider(),
          itemBuilder: (context, index) {
            var teacher = controller.teacherList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(teacher['avatar_url'] ?? "https://i.pravatar.cc/300"),
                radius: 25,
              ),
              title: Text(teacher['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(teacher['designation'] ?? "Teacher"),
              trailing: IconButton(
                icon: const Icon(Icons.email, color: Colors.blueAccent),
                onPressed: () {
                  Get.snackbar("Contact", "Email: ${teacher['email']}");
                },
              ),
            );
          },
        );
      }),
    );
  }
}
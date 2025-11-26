import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_controller.dart';

class PendingRequestsScreen extends StatelessWidget {
  final StaffController controller = Get.put(StaffController());

  PendingRequestsScreen({super.key}) {
    controller.fetchPendingUsers(); // পেজে ঢুকেই লোড করবে
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Signups"), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.pendingList.isEmpty) {
          return const Center(child: Text("No pending requests 🎉"));
        }

        return ListView.builder(
          itemCount: controller.pendingList.length,
          itemBuilder: (context, index) {
            var user = controller.pendingList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
                title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${user['role'].toUpperCase()} | ID: ${user['student_id'] ?? user['designation'] ?? 'N/A'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Approve Button
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => controller.approveUser(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
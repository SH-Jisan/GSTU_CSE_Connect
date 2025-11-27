//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\profile\edit_profile_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class EditProfileSheet extends StatelessWidget {
  final ProfileController controller = Get.find();

  // আগের ডাটা দিয়ে ফর্ম ফিলাপ করার জন্য কন্ট্রোলার
  final TextEditingController nameCtrl;
  final TextEditingController desigCtrl;

  EditProfileSheet({super.key, required String currentName, required String currentDesig})
      : nameCtrl = TextEditingController(text: currentName),
        desigCtrl = TextEditingController(text: currentDesig);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🏷️ Header
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 📸 Image Picker Circle
            GetBuilder<ProfileController>(
                builder: (ctrl) {
                  return GestureDetector(
                    onTap: () {
                      print("🔘 Avatar Tapped! Opening Gallery...");
                      ctrl.pickImage();
                    },// ছবি সিলেক্ট করার ফাংশন
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: ctrl.selectedImage != null
                              ? FileImage(ctrl.selectedImage!) // গ্যালারি থেকে নেওয়া ছবি
                              : null, // আগে ছবি না থাকলে
                          child: ctrl.selectedImage == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        // ক্যামেরা আইকন
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  );
                }
            ),
            const SizedBox(height: 10),
            const Text("Tap to change photo", style: TextStyle(fontSize: 12, color: Colors.grey)),

            const SizedBox(height: 30),

            // 📝 Name Field
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // 📝 Designation Field (শুধুমাত্র স্টাফ/টিচারদের জন্য জরুরি)
            TextField(
              controller: desigCtrl,
              decoration: InputDecoration(
                labelText: "Designation / Bio",
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            // 💾 Update Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  // আপডেট ফাংশন কল
                  controller.updateProfile(nameCtrl.text, desigCtrl.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
            ),
            const SizedBox(height: 20), // কি-বোর্ডের জন্য জায়গা
          ],
        ),
      ),
    );
  }
}
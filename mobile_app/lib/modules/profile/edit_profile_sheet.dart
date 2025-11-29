import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../student/controllers/batch_controller.dart';

class EditProfileSheet extends StatelessWidget {
  final ProfileController controller = Get.find();
  final BatchController batchCtrl = Get.put(BatchController());

  final TextEditingController nameCtrl;
  final TextEditingController desigCtrl;
  final TextEditingController phoneCtrl;

  final String role;

  EditProfileSheet({
    super.key,
    required String currentName,
    required String currentDesig,
    required String currentPhone,
    // 🆕 Notun duita parameter nilam
    required String? currentYear,
    required String? currentSemester,
    required this.role,
  })  : nameCtrl = TextEditingController(text: currentName),
        desigCtrl = TextEditingController(text: currentDesig),
        phoneCtrl = TextEditingController(text: currentPhone) {

    // 🪄 Magic Fix: Sheet open howar sathe sathe value set kora holo
    batchCtrl.setInitialValues(currentYear, currentSemester);
  }

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
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Image Picker
            GetBuilder<ProfileController>(builder: (ctrl) {
              return GestureDetector(
                onTap: () => ctrl.pickImage(),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: ctrl.selectedImage != null
                          ? FileImage(ctrl.selectedImage!)
                          : null,
                      child: ctrl.selectedImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),

            // Text Fields
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: "Full Name", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: desigCtrl,
              decoration: InputDecoration(labelText: "Designation / Bio", prefixIcon: const Icon(Icons.work_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number", prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),

            const SizedBox(height: 10),

            Obx(() => SwitchListTile(
              title: const Text("Make Phone Number Public?"),
              subtitle: Text(controller.isPhonePublic.value ? "Everyone can see & call" : "Only Admin can see", style: TextStyle(fontSize: 12, color: controller.isPhonePublic.value ? Colors.green : Colors.grey)),
              value: controller.isPhonePublic.value,
              onChanged: (val) => controller.isPhonePublic.value = val,
              activeColor: Colors.blueAccent,
            )),

            const SizedBox(height: 20),

            // 🎓 Batch Update UI
            if (role == 'student') ...[
              const Divider(),
              const Text("Academic Info (Batch)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildDropdown("Year", batchCtrl.selectedYear, ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Graduated'])),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => batchCtrl.selectedYear.value == 'Graduated'
                        ? const SizedBox()
                        : _buildDropdown("Semester", batchCtrl.selectedSemester, ['1st Semester', '2nd Semester'])),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // 💾 Unified Save Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => (controller.isLoading.value || batchCtrl.isLoading.value)
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  // 1. Jodi Student hoy, age Batch update koro
                  if (role == 'student') {
                    if (batchCtrl.selectedYear.value == 'Graduated') {
                      batchCtrl.selectedSemester.value = "Completed";
                    }
                    await batchCtrl.updateBatchStatus(); // await added
                  }

                  // 2. Tarpor Main Profile update koro
                  controller.updateProfile(
                    nameCtrl.text,
                    desigCtrl.text,
                    phoneCtrl.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save Edits", style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, RxString value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value.value) ? value.value : items.first,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => value.value = val!,
        ),
      ),
    );
  }
}
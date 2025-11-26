import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var noticeList = [].obs; // নোটিস লিস্ট
  var isLoading = true.obs; // লোডিং অবস্থা
  var userName = "".obs; // ইউজারের নাম
  var userRole = "".obs;

  @override
  void onInit() {
    loadUserData();
    fetchNotices();
    super.onInit();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('userName') ?? "Student";
    userRole.value = prefs.getString('userRole') ?? "student";
  }

  void fetchNotices() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.noticeEndpoint));
      if (response.statusCode == 200) {
        noticeList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch notices");
    } finally {
      isLoading(false);
    }
  }

  // 🗑️ Notice Delete Function (Native Dialog Fix)
  void deleteNotice(int id) {
    // Get.context চেক করা (সেফটি)
    if (Get.context == null) return;

    // ⚠️ ফিক্স: Get.dialog এর বদলে showDialog ব্যবহার করা হলো
    showDialog(
      context: Get.context!,
      barrierDismissible: false, // বাইরে ক্লিক করলে যাবে না
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever, size: 40, color: Colors.red),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Delete Notice?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Are you sure? This cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // ⚠️ ফিক্স: নেটিভ পপ ব্যবহার করা হলো
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          // ⚠️ ফিক্স: আগে ডায়ালগ নিশ্চিতভাবে বন্ধ করো
                          Navigator.of(context).pop();

                          // এরপর ডিলিট লজিক কল করো (আলাদা ফাংশনে বা এখানেই)
                          _confirmDeleteAPI(id);
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 আসল ডিলিট লজিক (Private Function)
  void _confirmDeleteAPI(int id) async {
    isLoading(true);
    try {
      var response = await http.delete(Uri.parse("${ApiConstants.noticeEndpoint}/$id"));

      if (response.statusCode == 200) {
        Get.snackbar(
            "Deleted",
            "Notice removed successfully",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2)
        );
        fetchNotices(); // লিস্ট রিফ্রেশ
      } else {
        Get.snackbar("Error", "Failed to delete");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed");
    } finally {
      isLoading(false);
    }
  }

  // ✏️ Notice Edit Function (Premium UI)
  void editNotice(Map notice) {
    final titleCtrl = TextEditingController(text: notice['title']);
    final descCtrl = TextEditingController(text: notice['description']);
    var selectedCat = (notice['category'] ?? "General").toString().obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView( // কি-বোর্ড উঠলে যাতে এরর না দেয়
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Section (Blue Top)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.edit_note_rounded, size: 50, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      "Update Notice",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Form Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['General', 'Exam', 'Holiday', 'Scholarship', 'Urgent'].contains(selectedCat.value)
                              ? selectedCat.value
                              : 'General',
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent),
                          items: ['General', 'Exam', 'Holiday', 'Scholarship', 'Urgent']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => selectedCat.value = v!,
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),

                    // Description Field
                    const Text("Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write details here...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 3. Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Update Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.back(); // ডায়ালগ বন্ধ
                              isLoading(true);
                              try {
                                var response = await http.put(
                                  Uri.parse("${ApiConstants.noticeEndpoint}/${notice['id']}"),
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode({
                                    "title": titleCtrl.text,
                                    "description": descCtrl.text,
                                    "category": selectedCat.value
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  Get.snackbar(
                                      "Success! ✅",
                                      "Notice Updated Successfully",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(10)
                                  );
                                  fetchNotices(); // রিফ্রেশ
                                } else {
                                  Get.snackbar("Error", "Update Failed");
                                }
                              } catch (e) {
                                Get.snackbar("Error", "Connection Error");
                              } finally {
                                isLoading(false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Update", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // বাইরে ক্লিক করলে যাবে না
    );
  }
}
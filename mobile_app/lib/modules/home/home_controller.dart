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
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';

class MaterialController extends GetxController {
  var isLoading = false.obs;
  var courseList = [].obs;
  var materialList = [].obs;
  var userRole = "".obs;
  var currentUserId = 0.obs;

  // 🆕 পাবলিক/প্রাইভেট টগল করার জন্য
  var isPublic = true.obs;

  @override
  void onInit() {
    getUserRole();
    fetchPublicCourses();
    super.onInit();
  }

  void getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('userRole') ?? "student";

    currentUserId.value = prefs.getInt('userId') ?? 0;
  }

  void fetchPublicCourses() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.courseListEndpoint));
      if (response.statusCode == 200) {
        courseList.value = jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching courses");
    } finally {
      isLoading(false);
    }
  }

  // 2. নির্দিষ্ট কোর্সের ম্যাটেরিয়াল আনা (Updated with UserID)
  void fetchMaterials(int courseId) async {
    try {
      isLoading(true);

      // ⚠️ ইউজারের আইডি পাঠাতে হবে প্রাইভেট ফাইল দেখার জন্য
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      // লিংক আপডেট: ?userId=... যোগ করা হলো
      var response = await http.get(Uri.parse("${ApiConstants.materialEndpoint}/$courseId?userId=$userId"));

      if (response.statusCode == 200) {
        materialList.value = jsonDecode(response.body);
      } else {
        materialList.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not load materials");
    } finally {
      isLoading(false);
    }
  }

  // 3. ফাইল আপলোড (Updated UI with Switch)
  void pickAndUploadFile(int courseId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        final titleCtrl = TextEditingController();

        // ডিফল্ট পাবলিক থাকবে
        isPublic.value = true;

        // 🆕 ডায়ালগ বক্স আপডেট (সুইচ সহ)
        Get.defaultDialog(
            title: "Upload File",
            content: Column(
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                        hintText: "File Title (e.g. Lecture 1)",
                        border: OutlineInputBorder()
                    )
                ),
                const SizedBox(height: 10),

                // পাবলিক/প্রাইভেট সুইচ
                Obx(() => SwitchListTile(
                  title: Text(isPublic.value ? "Public (Everyone)" : "Private (Only Me)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPublic.value ? Colors.green : Colors.red
                      )
                  ),
                  value: isPublic.value,
                  onChanged: (val) => isPublic.value = val,
                  secondary: Icon(isPublic.value ? Icons.public : Icons.lock),
                )),
              ],
            ),
            textConfirm: "Upload",
            textCancel: "Cancel",
            confirmTextColor: Colors.white,
            onConfirm: () async {
              Get.back();
              _uploadToServer(file, courseId, titleCtrl.text);
            }
        );
      }
    } catch (e) {
      Get.snackbar("Error", "File pick cancelled");
    }
  }

  // আসল আপলোড লজিক (Updated Body)
  void _uploadToServer(File file, int courseId, String title) async {
    if (title.isEmpty) {
      Get.snackbar("Error", "Title is required");
      return;
    }

    isLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      List<int> fileBytes = await file.readAsBytes();
      String extension = file.path.split('.').last.toLowerCase();

      String mimeType = "application/octet-stream";
      if (extension == 'pdf') mimeType = "application/pdf";
      else if (extension == 'png') mimeType = "image/png";
      else if (extension == 'jpg' || extension == 'jpeg') mimeType = "image/jpeg";
      else if (extension == 'doc' || extension == 'docx') mimeType = "application/msword";

      String base64File = "data:$mimeType;base64,${base64Encode(fileBytes)}";

      var bodyData = {
        "course_id": courseId,
        "title": title,
        "file_base64": base64File,
        "file_type": extension,
        "uploaded_by": userId,
        "is_public": isPublic.value // ⚠️ পাঠাচ্ছি (True/False)
      };

      var response = await http.post(
        Uri.parse("${ApiConstants.materialEndpoint}/upload"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Material Uploaded! 📂", backgroundColor: Colors.green, colorText: Colors.white);
        fetchMaterials(courseId);
      } else {
        Get.snackbar("Failed", "Upload failed. Check file size.");
      }
    } catch (e) {
      print("Upload Error: $e");
      Get.snackbar("Error", "Check internet connection");
    } finally {
      isLoading(false);
    }
  }

  void openMaterial(String url) async {
    if (url.startsWith("http://")) {
      url = url.replaceFirst("http://", "https://");
    }
    bool isPdf = url.toLowerCase().contains(".pdf");
    Uri uri;
    if (isPdf) {
      String googleDocsUrl = "https://docs.google.com/viewer?url=$url";
      uri = Uri.parse(googleDocsUrl);
    } else {
      uri = Uri.parse(url);
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "Could not open file.");
      }
    } catch (e) {
      Get.snackbar("Error", "No browser found.");
    }
  }

  void deleteMaterial(int id, int courseId) {
    Get.defaultDialog(
        title: "Delete?",
        middleText: "Are you sure?",
        onConfirm: () async {
          Get.back();
          await http.delete(Uri.parse("${ApiConstants.materialEndpoint}/$id"));
          fetchMaterials(courseId);
        }
    );
  }
  void toggleVisibility(int id, int courseId) async {
    try {
      var response = await http.put(Uri.parse("${ApiConstants.materialEndpoint}/toggle/$id"));

      if (response.statusCode == 200) {
        Get.snackbar("Updated", "File visibility changed successfully");
        fetchMaterials(courseId); // List refresh koro jate UI update hoy
      } else {
        Get.snackbar("Error", "Failed to update status");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection Error");
    }
  }
}
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../auth/login_screen.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;

  // 🛠️ FIX: টাইপ নির্দিষ্ট করে দেওয়া হলো <String, dynamic>
  // এতে নাল ভ্যালু আসলেও অ্যাপ ক্র্যাশ করবে না
  var userData = <String, dynamic>{}.obs;

  var isPhonePublic = false.obs;

  File? selectedImage;
  String? base64Image;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  // 📥 Fetch Profile Data
  void fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.profileEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        userData.value = data;

        // Privacy Status Load
        var publicStatus = data['is_phone_public'];
        isPhonePublic.value = (publicStatus == true || publicStatus.toString() == 'true');
      }
    } catch (e) {
      Get.snackbar("Error", "Could not load profile");
    } finally {
      isLoading(false);
    }
  }

  // 📸 Image Picker
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage = File(image.path);
        List<int> imageBytes = await selectedImage!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(imageBytes)}";
        update();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not pick image");
    }
  }

  // ✏️ Update Profile
  void updateProfile(String name, String designation, String phone) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        Get.snackbar("Error", "Session Expired. Login again.");
        return;
      }

      // 🛠️ FIX: এখানেও টাইপ <String, dynamic> বলে দিচ্ছি
      Map<String, dynamic> bodyData = {
        "id": userId,
        "name": name,
        "designation": designation,
        "phone": phone,
        "is_phone_public": isPhonePublic.value,
      };

      // Image থাকলে add করব
      if (base64Image != null) {
        bodyData["image_base64"] = base64Image;
      }

      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/auth/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var updatedUser = data['user'];

        // Local Updates
        userData.value = updatedUser;
        await prefs.setString('userName', updatedUser['name']);

        selectedImage = null;
        base64Image = null;

        Get.snackbar("Success", "Profile Updated! ✅", backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      } else {
        Get.snackbar("Error", "Update Failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🚪 Logout
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => LoginScreen());
  }
}
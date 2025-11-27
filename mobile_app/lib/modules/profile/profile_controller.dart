//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\profile\profile_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../auth/login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var userData = {}.obs; // ইউজারের সব ডাটা এখানে থাকবে

  File? selectedImage;
  String? base64Image;


  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }
  // 📸 গ্যালারি থেকে ছবি নেওয়া (Debugged)
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage = File(image.path);

        // Base64 কনভার্সন
        List<int> imageBytes = await selectedImage!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(imageBytes)}";

        // 🕵️ ডিবাগ প্রিন্ট: ছবি সিলেক্ট হয়েছে কিনা
        print("📸 IMAGE SELECTED!");
        print("📸 Path: ${image.path}");
        print("📸 Base64 String Length: ${base64Image?.length}"); // এটা যদি 0 বা null হয়, তবেই সমস্যা

        update(); // UI আপডেট করার জন্য (GetBuilder এর জন্য জরুরি)
      } else {
        print("⚠️ No image selected (User cancelled)");
      }
    } catch (e) {
      print("❌ Image Picker Error: $e");
      Get.snackbar("Error", "Could not pick image");
    }
  }

  // ✏️ প্রোফাইল আপডেট ফাংশন (Debugged)
  void updateProfile(String name, String designation) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      // 🕵️ পাঠানোর আগে ফাইনাল চেক
      print("🚀 PREPARING TO SEND DATA...");
      print("🆔 User ID: $userId");
      print("📸 Is Base64 Null?: ${base64Image == null}");

      if (base64Image != null) {
        print("📸 Sending Image Data Length: ${base64Image!.length}");
      } else {
        print("⚠️ WARNING: Sending Request WITHOUT Image!");
      }

      var bodyData = {
        "id": userId,
        "name": name,
        "designation": designation,
        // যদি null না হয়, তবেই ম্যাপে যোগ হবে
        if (base64Image != null) "image_base64": base64Image,
      };

      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/auth/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      print("📥 Server Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var updatedUser = data['user'];

        userData.value = updatedUser;
        await prefs.setString('userName', updatedUser['name']);

        // সফল হওয়ার পর ইমেজ ভেরিয়েবল রিসেট করো
        selectedImage = null;
        base64Image = null;

        Get.snackbar("Success", "Profile Updated! 📸", backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      } else {
        Get.snackbar("Error", "Update Failed");
      }
    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar("Error", "Connection Error");
    } finally {
      isLoading(false);
    }
  }
  // 📥 প্রোফাইল ডাটা লোড করা
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
        userData.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not load profile");
    } finally {
      isLoading(false);
    }
  }

  // 🚪 লগআউট ফাংশন
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // সব ডাটা মুছে ফেলা
    Get.offAll(() => LoginScreen()); // লগইন স্ক্রিনে পাঠিয়ে দেওয়া
  }



}
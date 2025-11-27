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

  Future<void> pickImage() async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null){
      selectedImage = File(image.path);

      List<int> imageBytes = await selectedImage!.readAsBytes();
      base64Image = "data:image/jpeg;base63,${base64Encode(imageBytes)}";

      update();
      Get.snackbar("Selected", "Image selected successfully!");
    }
  }



  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }
// ✏️ প্রোফাইল আপডেট ফাংশন (Image Update Fix)
  void updateProfile(String name, String designation) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        Get.snackbar("Error", "Session Expired. Login again.");
        return;
      }

      var bodyData = {
        "id": userId,
        "name": name,
        "designation": designation,
        if (base64Image != null) "image_base64": base64Image,
      };

      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/auth/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      print("📥 Server Response: ${response.body}");

      if (response.statusCode == 200) {
        // ১. সার্ভার থেকে আপডেটেড ইউজার ডাটা নিলাম
        var data = jsonDecode(response.body);
        var updatedUser = data['user'];

        // ২. লোকাল মেমোরি (Observable) আপডেট করলাম (যাতে সাথে সাথে UI চেঞ্জ হয়)
        userData.value = updatedUser;

        // ৩. টেম্পোরারি ইমেজ ক্লিয়ার করলাম
        selectedImage = null;
        base64Image = null;

        // ৪. SharedPreferences-এও নাম আপডেট করে দিই
        await prefs.setString('userName', updatedUser['name']);

        Get.snackbar("Success", "Profile Updated Successfully! 📸", backgroundColor: Colors.green, colorText: Colors.white);

        Get.back(); // শিট বন্ধ
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
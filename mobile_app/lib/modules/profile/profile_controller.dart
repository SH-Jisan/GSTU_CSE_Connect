import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../auth/login_screen.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var userData = {}.obs; // ইউজারের সব ডাটা এখানে থাকবে

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
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
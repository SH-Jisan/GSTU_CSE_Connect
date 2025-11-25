import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var noticeList = [].obs; // নোটিস লিস্ট
  var isLoading = true.obs; // লোডিং অবস্থা
  var userName = "".obs; // ইউজারের নাম

  @override
  void onInit() {
    loadUserData();
    fetchNotices();
    super.onInit();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('userName') ?? "Student";
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
}
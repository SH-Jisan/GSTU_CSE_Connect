import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';

class StaffController extends GetxController {
  var pendingList = [].obs;
  var isLoading = true.obs;

  // পেন্ডিং লিস্ট লোড করা
  void fetchPendingUsers() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.pendingUsersEndpoint));
      if (response.statusCode == 200) {
        pendingList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch requests");
    } finally {
      isLoading(false);
    }
  }

  // অ্যাপ্রুভ করা
  void approveUser(int id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.approveUserEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Success", "User Approved!");
        fetchPendingUsers(); // লিস্ট রিফ্রেশ
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to approve");
    }
  }
}
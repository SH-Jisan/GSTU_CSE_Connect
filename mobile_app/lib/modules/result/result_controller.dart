import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ResultController extends GetxController {
  var resultList = [].obs;
  var isLoading = true.obs;
  var cgpa = 0.0.obs; // গড় জিপিএ দেখানোর জন্য

  @override
  void onInit() {
    fetchResults();
    super.onInit();
  }

  void fetchResults() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.resultEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        resultList.value = data;
        calculateCGPA(data);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch results");
    } finally {
      isLoading(false);
    }
  }

  // ছোট লজিক: গড় CGPA বের করা
  void calculateCGPA(List data) {
    if (data.isEmpty) return;
    double totalGpa = 0;
    for (var item in data) {
      totalGpa += double.parse(item['gpa'].toString());
    }
    cgpa.value = totalGpa / data.length;
  }
}
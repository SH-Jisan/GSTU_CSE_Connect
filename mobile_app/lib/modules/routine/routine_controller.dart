import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';

class RoutineController extends GetxController {
  var routineList = [].obs;
  var isLoading = true.obs;
  var userRole = "".obs;

  final box = GetStorage();

  @override
  void onInit() {
    getUserRole();

    // 1. Offline Data Load
    var savedRoutine = box.read('routine');
    if (savedRoutine != null) {
      routineList.value = savedRoutine;
      isLoading(false);
    }

    fetchRoutine(); // 2. Online Update
    super.onInit();
  }

  void getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('userRole') ?? "student";
  }

  void fetchRoutine() async {
    try {
      if (routineList.isEmpty) isLoading(true);

      var response = await http.get(Uri.parse(ApiConstants.routineEndpoint));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        routineList.value = data;

        // 3. Save Data
        box.write('routine', data);
      }
    } catch (e) {
      print("Offline Mode Active");
    } finally {
      isLoading(false);
    }
  }

  // 📂 গ্রুপিং লজিক: সেমিস্টার অনুযায়ী সাজানো
  Map<String, List<dynamic>> get groupedRoutines {
    Map<String, List<dynamic>> grouped = {};

    for (var routine in routineList) {
      String semester = routine['semester'] ?? "Unknown";

      if (!grouped.containsKey(semester)) {
        grouped[semester] = [];
      }
      grouped[semester]!.add(routine);
    }

    // সেমিস্টার নাম অনুযায়ী সর্ট করা (অপশনাল, ডাটাবেস থেকেও সর্টেড আসে)
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  // 🔴 ক্লাস ক্যানসেল ফাংশন (টিচারদের জন্য)
  void toggleClassStatus(int id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.cancelClassEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Class status updated!");
        fetchRoutine(); // রিফ্রেশ
      }
    } catch (e) {
      Get.snackbar("Error", "Could not update status");
    }
  }
}
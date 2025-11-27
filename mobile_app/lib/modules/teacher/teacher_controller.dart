//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\teacher\teacher_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';

class TeacherController extends GetxController {
  var teacherList = [].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchTeachers();
    super.onInit();
  }

  void fetchTeachers() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.teacherEndpoint));
      if (response.statusCode == 200) {
        teacherList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch teacher list");
    } finally {
      isLoading(false);
    }
  }
}
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineController extends GetxController {
  var routineList = [].obs;
  var isLoading = true.obs;
  var userRole = "".obs;

  @override
  void onInit() {
    getUserRole();
    fetchRoutine();
    super.onInit();
  }

  // ইউজার রোল বের করা
  void getUserRole() async{
    final prefs = await SharedPreferences.getInstance();
    // আমরা login এর সময় role সেভ করিনি, তাই আপাতত টোকেন ডিকোড না করে
    // প্রোফাইল থেকে রোলটা এনে সেভ করা ভালো ছিল।
    // সহজ করার জন্য ধরে নিচ্ছি আমরা ইমেইল দিয়ে চেক করব বা লগইন কন্ট্রোলারে রোল সেভ করেছিলাম।
    // *কুইক ফিক্স:* আমরা ধরে নিচ্ছি Tanvir Sir লগইন করলে তিনি টিচার।
    // রিয়েল অ্যাপে login_screen.dart এ prefs.setString('role', role) করতে হবে।

    // আপাতত ম্যানুয়ালি চেক করি
    String? email = prefs.getString('userEmail');
    if(email != null && email.contains("tanvir")){
      userRole.value = 'teacher';
    }
    else{
      userRole.value = 'student';
    }
  }

  void fetchRoutine() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.routineEndpoint));
      if (response.statusCode == 200) {
        routineList.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch routine");
    } finally {
      isLoading(false);
    }
  }

  // ক্লাস ক্যানসেল করার ফাংশন
  void toggleClassStatus(int id) async{
    try{
      var response = await http.post(
        Uri.parse(ApiConstants.cancelClassEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if(response.statusCode == 200){
        Get.snackbar("Success", "Class status updated!");
        fetchRoutine();
      }
    }
    catch(e){
      Get.snackbar("Error" , "Could not update status");
    }
  }
}
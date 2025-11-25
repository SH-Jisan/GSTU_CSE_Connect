import 'package:get/get.dart';

class DashboardController extends GetxController {
  // বর্তমানে কোন ট্যাব সিলেক্ট করা আছে (0 = Home)
  var tabIndex = 0.obs;

  // ট্যাব পরিবর্তন করার ফাংশন
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
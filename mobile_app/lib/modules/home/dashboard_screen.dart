import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/modules/home/home_screen.dart';
import 'dashboard_controller.dart';
import '../routine/routine_screen.dart';
import '../profile/profile_screen.dart';
import '../result/result_screen.dart';
import '../teacher/teacher_list_screen.dart';

// ডামি পেজ (পরে এগুলো আসল পেজ দিয়ে রিপ্লেস করব)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার ইনিশিয়ালাইজ করা
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      // উপরের বার
      appBar: AppBar(
        title: const Text("GSTU CSE Connect"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      // ... AppBar এর পরে ...
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text("GSTU CSE Dept"),
              accountEmail: Text("Smart Dept App"),
              currentAccountPicture: Icon(Icons.school, size: 50, color: Colors.white),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Faculty Members'),
              onTap: () => Get.to(() => TeacherListScreen()), // টিচার লিস্টে যাবে
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Course Materials'),
              onTap: () {
                Get.snackbar("Coming Soon", "Material feature is under development!");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About App'),
              onTap: () {},
            ),
          ],
        ),
      ),
// ... Body ...

      // বডি: যা ইনডেক্স অনুযায়ী চেঞ্জ হবে
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          HomeScreen(),    // Index 0
          RoutineScreen(), // Index 1
          ResultScreen(),
          ProfileScreen(), // Index 2
        ],
      )),

      // নিচের নেভিগেশন বার
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Result'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}
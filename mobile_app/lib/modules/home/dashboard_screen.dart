//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\home\dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_controller.dart';
import 'home_screen.dart';
import '../routine/routine_screen.dart';
import '../result/result_screen.dart';
import '../profile/profile_screen.dart';
import '../staff/staff_dashboard.dart'; // স্টাফ প্যানেল ইম্পোর্ট
import '../teacher/teacher_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.put(DashboardController());
  String userRole = 'student'; // ডিফল্ট

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // 🕵️ রোল চেক করা
  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? 'student';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📋 স্টাফদের জন্য পেজ লিস্ট
    List<Widget> staffPages = [
      HomeScreen(),         // 0: Notice Board (Edit/Delete সহ)
      RoutineScreen(),      // 1: Routine
      const StaffDashboard(),// 2: Admin Panel (4টা বাটন এখানে থাকবে)
      ProfileScreen(),      // 3: Profile (Edit সহ)
    ];

    // 🎓 স্টুডেন্ট/টিচারদের জন্য পেজ লিস্ট
    List<Widget> studentPages = [
      HomeScreen(),
      RoutineScreen(),
      ResultScreen(),       // স্টুডেন্টরা রেজাল্ট দেখবে
      ProfileScreen(),
    ];

    return Scaffold(
      // AppBar ড্যাশবোর্ড থেকে সরিয়ে দিলাম, কারণ একেক পেজের টাইটেল একেক রকম হতে পারে
      // তবে চাইলে রাখতে পারো। আমি আপাতত রাখছি।
      appBar: AppBar(
        title: const Text("GSTU CSE Connect"),
        centerTitle: true,
        backgroundColor: userRole == 'staff' ? Colors.indigo : Colors.blueAccent, // স্টাফ হলে কালার আলাদা
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration( color: userRole == 'staff' ? Colors.indigo : Colors.blueAccent,
              ),
              accountName: const Text("GSTU CSE Dept"),
              accountEmail: const Text("Smart Dept App"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 40, color: Colors.blueAccent),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Faculty Members"),
              onTap: (){
                Get.back();
                Get.to(() => TeacherListScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Course Materials"),
              onTap: (){
                Get.back();
                Get.snackbar("Coming Soon", "Feature under development");
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

      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: userRole == 'staff' ? staffPages : studentPages,
      )),

      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: userRole == 'staff' ? Colors.indigo : Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: userRole == 'staff'
            ? const [ // 🛡️ স্টাফ মেনু
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'), // Result এর বদলে Admin
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ]
            : const [ // 🎓 স্টুডেন্ট মেনু
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Result'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      )),
    );
  }
}
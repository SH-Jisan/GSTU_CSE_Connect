import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_controller.dart';
import 'course_material_screen.dart';

class PublicCourseListScreen extends StatelessWidget {
  final MaterialController controller = Get.put(MaterialController());

  PublicCourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Materials"), backgroundColor: Colors.teal),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        // সেমিস্টার অনুযায়ী গ্রুপ করা (একই লজিক যা স্টাফে করেছিলাম)
        var grouped = {};
        for (var course in controller.courseList) {
          String sem = course['semester'];
          if (!grouped.containsKey(sem)) grouped[sem] = [];
          grouped[sem]!.add(course);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            String semester = grouped.keys.elementAt(index);
            List courses = grouped[semester];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text(semester, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                leading: const Icon(Icons.folder, color: Colors.teal),
                children: courses.map((course) => ListTile(
                  title: Text(course['course_code']),
                  subtitle: Text(course['course_title']),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // কোর্সের ভেতরে ঢুকলে ম্যাটেরিয়াল পেজ আসবে
                    Get.to(() => CourseMaterialScreen(
                        courseId: course['id'],
                        courseName: course['course_title']
                    ));
                  },
                )).toList(),
              ),
            );
          },
        );
      }),
    );
  }
}
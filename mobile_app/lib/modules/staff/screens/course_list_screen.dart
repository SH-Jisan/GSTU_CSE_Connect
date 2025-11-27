import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/staff_course_controller.dart';

class CourseListScreen extends StatelessWidget {
  final StaffCourseController controller = Get.put(StaffCourseController());

  CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Course Manager"), backgroundColor: Colors.brown, foregroundColor: Colors.white),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Course", style: TextStyle(color: Colors.white)),
        onPressed: () {
          controller.clearFields(); // নতুন এন্ট্রির জন্য সব ক্লিয়ার
          _showCourseForm(context, isEdit: false);
        },
      ),

      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.courseList.isEmpty) return const Center(child: Text("No courses added yet."));

        // 📂 Grouped List Logic
        var grouped = controller.groupedCourses;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            String semester = grouped.keys.elementAt(index);
            List courses = grouped[semester]!;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ExpansionTile(
                title: Text(semester, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                leading: const Icon(Icons.school, color: Colors.brown),
                children: courses.map((course) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  title: Text(course['course_code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(course['course_title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✏️ Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          controller.setFieldsForEdit(course);
                          _showCourseForm(context, isEdit: true, id: course['id']);
                        },
                      ),
                      // 🗑️ Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteCourse(course['id']),
                      ),
                    ],
                  ),
                  // Syllabus View
                  onTap: () => Get.defaultDialog(
                    title: "Syllabus: ${course['course_code']}",
                    content: Container(
                      height: 200,
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
                      child: SingleChildScrollView(child: Text(course['syllabus'] ?? "No description.")),
                    ),
                    textCancel: "Close",
                  ),
                )).toList(),
              ),
            );
          },
        );
      }),
    );
  }

  // 📝 Beautiful Bottom Sheet Form
  void _showCourseForm(BuildContext context, {required bool isEdit, int? id}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(isEdit ? "Edit Course" : "Add New Course", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 20),

              // Fields
              _buildTextField(controller.codeCtrl, "Course Code", Icons.qr_code),
              _buildTextField(controller.titleCtrl, "Course Title", Icons.title),

              // Semester Dropdown
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedSemester.value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.brown),
                    items: [
                      '1st Year 1st Sem', '1st Year 2nd Sem',
                      '2nd Year 1st Sem', '2nd Year 2nd Sem',
                      '3rd Year 1st Sem', '3rd Year 2nd Sem',
                      '4th Year 1st Sem', '4th Year 2nd Sem',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => controller.selectedSemester.value = v!,
                  ),
                ),
              )),

              // 📖 Large Syllabus Field
              TextField(
                controller: controller.syllabusCtrl,
                maxLines: 5, // বড় বক্স
                decoration: InputDecoration(
                  labelText: "Detailed Syllabus",
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.menu_book),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (isEdit) {
                      controller.updateCourse(id!);
                    } else {
                      controller.addCourse();
                    }
                  },
                  child: Text(isEdit ? "Update Course" : "Save Course", style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20), // Keyboard space
            ],
          ),
        ),
      ),
      isScrollControlled: true, // পুরো স্ক্রিন পাওয়ার জন্য
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.brown),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
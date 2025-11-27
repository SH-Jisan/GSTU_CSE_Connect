//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\modules\result\result_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'result_controller.dart';

class ResultScreen extends StatelessWidget {
  final ResultController controller = Get.put(ResultController());

  ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🏆 উপরের জিপিএ কার্ড
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text("Calculated Average CGPA", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Obx(() => Text(
                  controller.cgpa.value.toStringAsFixed(2),
                  style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                )),
                const Text("Keep it up! 🌟", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📜 রেজাল্ট লিস্ট
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.resultList.isEmpty) {
                return const Center(child: Text("No results published yet."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.resultList.length,
                itemBuilder: (context, index) {
                  var result = controller.resultList[index];
                  // গ্রেড অনুযায়ী কালার
                  bool isGood = double.parse(result['gpa'].toString()) >= 3.0;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isGood ? Colors.green[50] : Colors.red[50],
                        child: Text(
                          result['grade'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isGood ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      title: Text(result['course_code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(result['semester']),
                      trailing: Text(
                        "${result['gpa']}",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
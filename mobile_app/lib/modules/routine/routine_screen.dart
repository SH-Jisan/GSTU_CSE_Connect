import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routine_controller.dart';


class RoutineScreen extends StatelessWidget {
  final RoutineController controller = Get.put(RoutineController());

  RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.routineList.isEmpty) {
          return const Center(child: Text("No classes found!"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.routineList.length,
          itemBuilder: (context, index) {
            var routine = controller.routineList[index];
            bool isCancelled = routine['is_cancelled'] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // বাম পাশের সময় (Time Column)
                  Column(
                    children: [
                      Text(
                        routine['start_time'].toString().substring(0, 5), // 10:00:00 থেকে 10:00
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(height: 40, width: 2, color: Colors.grey[300]), // দাগ
                      Text(
                        routine['end_time'].toString().substring(0, 5),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // ডান পাশের কার্ড (Class Card)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCancelled ? Colors.red[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCancelled ? Color.fromARGB(126, 237, 5, 24)
                              : Color.fromARGB(163, 4, 54, 223),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // সাবজেক্ট এবং ডে
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  routine['course_title'] ?? "No Title",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                                    color: isCancelled ? Colors.red : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Obx((){
                                if(controller.userRole.value == 'teacher'){
                                  return IconButton(
                                    icon:Icon(
                                      isCancelled ? Icons.restore : Icons.cancel,
                                      color: isCancelled ? Colors.green : Colors.red,
                                    ),
                                    onPressed: (){
                                      controller.toggleClassStatus(routine['id']);
                                    },
                                  );
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCancelled ? Colors.red : Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isCancelled ? "CANCELLED" : routine['day'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // রুম এবং টিচার
                          Row(
                            children: [
                              const Icon(Icons.room, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("Room ${routine['room_no']}"),
                              const SizedBox(width: 16),
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(routine['teacher_name'] ?? "Unknown", overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
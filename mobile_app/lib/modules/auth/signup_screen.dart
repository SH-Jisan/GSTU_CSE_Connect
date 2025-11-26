import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_controller.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final SignUpController controller = Get.put(SignUpController());

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 30),

              // 1. Role Selection Dropdown
              const Text("I am a:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedRole.value,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "student", child: Text("Student")),
                      DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                      DropdownMenuItem(value: "staff", child: Text("Office Staff")),
                    ],
                    onChanged: (value) {
                      controller.selectedRole.value = value!;
                    },
                  ),
                )),
              ),
              const SizedBox(height: 20),

              // 2. Common Fields (Name, Email, Pass)
              _buildTextField(controller.nameController, "Full Name", Icons.person),
              const SizedBox(height: 15),
              _buildTextField(controller.emailController, "Email Address", Icons.email),
              const SizedBox(height: 15),
              _buildTextField(controller.passwordController, "Password", Icons.lock, isObscure: true),
              const SizedBox(height: 15),

              // 3. Dynamic Fields (Logic based on Role)
              Obx(() {
                if (controller.selectedRole.value == 'student') {
                  return Column(
                    children: [
                      _buildTextField(controller.studentIdController, "Student ID (Roll)", Icons.badge),
                      const SizedBox(height: 15),
                      _buildTextField(controller.sessionController, "Session (e.g. 2019-20)", Icons.calendar_today),
                    ],
                  );
                } else {
                  return _buildTextField(controller.designationController, "Designation (e.g. Lecturer)", Icons.work);
                }
              }),

              const SizedBox(height: 30),

              // 4. Register Button
              Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () => controller.registerUser(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
              )),

              const SizedBox(height: 20),

              // 5. Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Get.off(() => LoginScreen()),
                    child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // হেল্পার উইজেট (টেক্সট ফিল্ড বানানোর জন্য)
  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // লোগো বা আইকন
                const Icon(Icons.school, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),

                const Text(
                  "GSTU CSE Connect",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // ইমেইল বক্স
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // পাসওয়ার্ড বক্স
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // লগইন বাটন (Obx দিয়ে র‍্যাপ করা যাতে লোডিং দেখায়)
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: () {
                    controller.login();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
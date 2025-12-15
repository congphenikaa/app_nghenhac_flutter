import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              const Text(
                "What's your name?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "What's your email?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Create a password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Create a password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. GIAO DIỆN Ô NHẬP LẠI MẬT KHẨU
              const Text(
                "Confirm password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Re-enter your password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1DB954),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // 3. LOGIC KIỂM TRA MẬT KHẨU KHỚP
                            String name = nameController.text.trim();
                            String email = emailController.text.trim();
                            String pass = passController.text.trim();
                            String confirmPass = confirmPassController.text
                                .trim();

                            if (name.isEmpty ||
                                email.isEmpty ||
                                pass.isEmpty ||
                                confirmPass.isEmpty) {
                              Get.snackbar(
                                "Lỗi",
                                "Vui lòng điền đầy đủ thông tin",
                                backgroundColor: Colors.red.withOpacity(0.5),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (pass != confirmPass) {
                              Get.snackbar(
                                "Lỗi",
                                "Mật khẩu nhập lại không khớp!",
                                backgroundColor: Colors.red.withOpacity(0.5),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (pass.length < 6) {
                              Get.snackbar(
                                "Yếu",
                                "Mật khẩu phải từ 6 ký tự trở lên",
                                backgroundColor: Colors.orange.withOpacity(0.5),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Nếu mọi thứ OK thì mới gọi API
                            controller.register(name, email, pass);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

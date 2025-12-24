import 'package:app_nghenhac/src/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/auth_controller.dart';

// 1. Định nghĩa bộ màu chuẩn theo file HTML
const Color kPrimaryColor = Color(0xFF30E87A); // Màu xanh neon chủ đạo
const Color kBackgroundDark = Color(0xFF112117); // Màu nền tối
const Color kSurfaceDark = Color(0xFF1D2E24); // Màu nền của các ô input
const Color kTextSecondary = Color(0xFF9DB8A8); // Màu chữ phụ

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller logic giữ nguyên
    final AuthController controller = Get.find<AuthController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    // Thêm biến để quản lý ẩn/hiện password (giống icon con mắt trong HTML)
    final RxBool isPassHidden = true.obs;
    final RxBool isConfirmPassHidden = true.obs;

    return Scaffold(
      backgroundColor: kBackgroundDark, //
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== 1. HEADER IMAGE SECTION ==================
            // Phần ảnh nền Concert + Gradient + Title
            SizedBox(
              height: Get.height * 0.35, // Chiếm khoảng 35% màn hình
              child: Stack(
                children: [
                  // Ảnh nền
                  Positioned.fill(
                    child: Image.asset(
                      'images/login.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: kSurfaceDark),
                    ),
                  ),
                  // Lớp phủ Gradient mờ dần xuống dưới
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kBackgroundDark.withOpacity(0.8),
                            kBackgroundDark,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Nội dung Header
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Icon tròn xanh giữa màn hình
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.graphic_eq,
                            size: 30,
                            color: kBackgroundDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Thế giới âm nhạc của bạn",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================== 2. FORM SECTION ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // --- Toggle Switch (Login / Register) ---
                  // Mô phỏng thanh chuyển tab trong HTML
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kSurfaceDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        // Tab Đăng nhập (Inactive)
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.to(LoginScreen()), // Quay về Login
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Text(
                                "Đăng nhập",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Tab Đăng ký (Active - Màu xanh)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              "Đăng ký",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kBackgroundDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- Input: Email ---
                  _buildInputField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.mail_outline, //
                  ),

                  const SizedBox(height: 15),

                  // --- Input: Mật khẩu ---
                  Obx(
                    () => _buildInputField(
                      controller: passController,
                      hintText: "Tạo mật khẩu",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscure: isPassHidden.value,
                      onToggleEye: () => isPassHidden.toggle(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- Input: Xác nhận mật khẩu ---
                  Obx(
                    () => _buildInputField(
                      controller: confirmPassController,
                      hintText: "Xác nhận mật khẩu",
                      icon: Icons.lock_reset, //
                      isPassword: true,
                      isObscure: isConfirmPassHidden.value,
                      onToggleEye: () => isConfirmPassHidden.toggle(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Nút Đăng ký (Register Button) ---
                  Obx(
                    () => controller.isLoading.value
                        ? const CircularProgressIndicator(color: kPrimaryColor)
                        : SizedBox(
                            width: double.infinity,
                            height: 56, // h-14 equivalent
                            child: ElevatedButton(
                              onPressed: () {
                                // Logic Validate cũ của bạn
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
                                    backgroundColor: Colors.red.withOpacity(
                                      0.5,
                                    ),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (pass != confirmPass) {
                                  Get.snackbar(
                                    "Lỗi",
                                    "Mật khẩu nhập lại không khớp!",
                                    backgroundColor: Colors.red.withOpacity(
                                      0.5,
                                    ),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (pass.length < 6) {
                                  Get.snackbar(
                                    "Yếu",
                                    "Mật khẩu phải từ 6 ký tự trở lên",
                                    backgroundColor: Colors.orange.withOpacity(
                                      0.5,
                                    ),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                controller.register(name, email, pass);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor, //
                                foregroundColor: kBackgroundDark,
                                elevation: 8,
                                shadowColor: kPrimaryColor.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Đăng ký",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 25),

                  // --- Divider "Hoặc đăng ký bằng" ---
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: kSurfaceDark, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "HOẶC ĐĂNG KÝ BẰNG",
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: kSurfaceDark, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Social Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.g_mobiledata, size: 40),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.apple, size: 30),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.facebook, size: 30),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Footer ---
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Bằng cách đăng ký, bạn đồng ý với Điều khoản & Chính sách của chúng tôi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Input Field Custom theo Style HTML
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleEye,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceDark, //
        borderRadius: BorderRadius.circular(16), // Rounded-xl
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kTextSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: kTextSecondary,
                  ),
                  onPressed: onToggleEye,
                )
              : null,
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  // Widget con: Social Button
  Widget _buildSocialButton(IconData icon, {double size = 24}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kSurfaceDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(50),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

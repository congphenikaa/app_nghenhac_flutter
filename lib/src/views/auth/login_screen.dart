import 'package:app_nghenhac/src/views/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/auth_controller.dart';

// Định nghĩa màu sắc theo mẫu HTML
const Color kPrimaryColor = Color(0xFF30E87A); // Màu xanh neon
const Color kBackgroundDark = Color(0xFF112117); // Nền đen xanh
const Color kSurfaceDark = Color(0xFF1D2E24); // Nền input
const Color kTextSecondary = Color(0xFF9DB8A8); // Màu chữ mờ

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    // Biến trạng thái ẩn/hiện mật khẩu
    final RxBool isObscure = true.obs;

    return Scaffold(
      backgroundColor: kBackgroundDark, //
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== 1. HEADER SECTION ==================
            // Phần ảnh nền và tiêu đề phía trên
            SizedBox(
              height: Get.height * 0.40, // Chiếm 40% màn hình
              width: double.infinity,
              child: Stack(
                children: [
                  // Ảnh nền (Dùng ảnh mạng hoặc asset)
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?q=80&w=2070&auto=format&fit=crop', // Ảnh concert mood
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[900]),
                    ),
                  ),
                  // Lớp phủ Gradient đen dần xuống dưới
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
                  // Nội dung Header (Icon + Text)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        // Icon tròn xanh
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.graphic_eq,
                            size: 32,
                            color: kBackgroundDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Thế giới âm nhạc của bạn",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28, // - text-[32px] approx
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Hàng triệu bài hát, miễn phí trên Spotify.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kTextSecondary, fontSize: 16),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Toggle Switch (Đăng nhập / Đăng ký) ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kSurfaceDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        // Tab Đăng nhập (Active)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: kPrimaryColor, // Active color
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Đăng nhập",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kBackgroundDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Tab Đăng ký (Inactive)
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.to(() => const RegisterScreen()),
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Text(
                                "Đăng ký",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Input Email ---
                  _buildInputField(
                    controller: emailController,
                    icon: Icons.mail_outline,
                    hintText: "Email hoặc Tên đăng nhập",
                  ),

                  const SizedBox(height: 16),

                  // --- Input Password ---
                  Obx(
                    () => _buildInputField(
                      controller: passController,
                      icon: Icons.lock_outline,
                      hintText: "Mật khẩu",
                      isPassword: true,
                      isObscure: isObscure.value,
                      onToggleEye: () => isObscure.toggle(),
                    ),
                  ),

                  // --- Quên mật khẩu ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          color: kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- Nút Đăng nhập ---
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          )
                        : SizedBox(
                            height: 56, // h-14 equivalent
                            child: ElevatedButton(
                              onPressed: () {
                                controller.login(
                                  emailController.text,
                                  passController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: kBackgroundDark,
                                shadowColor: kPrimaryColor.withOpacity(0.4),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 30),

                  // --- Divider "Hoặc tiếp tục với" ---
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: kSurfaceDark, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "HOẶC TIẾP TỤC VỚI",
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: kSurfaceDark, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Social Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        Icons.g_mobiledata,
                        size: 40,
                      ), // Google
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.apple, size: 30), // Apple
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.facebook, size: 30), // Facebook
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- Footer ---
                  const Text(
                    "Bằng cách tiếp tục, bạn đồng ý với Điều khoản của chúng tôi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Input Field được custom riêng
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
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
          prefixIcon: Icon(icon, color: kTextSecondary), // Icon bên trái
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
          border: InputBorder.none, // Xóa viền mặc định
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  // Widget con: Nút Social tròn
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

import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/auth_controller.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/social_login_button.dart';

const Color kPrimaryColor = Color(0xFF30E87A);
const Color kBackgroundDark = Color(0xFF112117);
const Color kSurfaceDark = Color(0xFF1D2E24);
const Color kTextSecondary = Color(0xFF9DB8A8);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    final RxBool isObscure = true.obs;

    return Scaffold(
      backgroundColor: kBackgroundDark,
      // Dùng Stack để đè lớp Loading lên trên cùng mọi thứ
      body: Stack(
        children: [
          // NỘI DUNG MÀN HÌNH CHÍNH
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.40,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'images/login.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[900]),
                        ),
                      ),
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
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
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
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Hàng triệu bài hát, miễn phí trên Spotify.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: kSurfaceDark,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
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
                            Expanded(
                              child: InkWell(
                                onTap: () => Get.toNamed(AppRoutes.REGISTER),
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                      CustomTextField(
                        controller: emailController,
                        icon: Icons.mail_outline,
                        hintText: "Email hoặc Tên đăng nhập",
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => CustomTextField(
                          controller: passController,
                          icon: Icons.lock_outline,
                          hintText: "Mật khẩu",
                          isPassword: true,
                          isObscure: isObscure.value,
                          onToggleEye: () => isObscure.toggle(),
                        ),
                      ),
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

                      // Nút đăng nhập thủ công
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => controller.login(
                            emailController.text,
                            passController.text,
                          ),
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
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: kSurfaceDark, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
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

                      // --- GỌI TRỰC TIẾP HÀM BÊN TRONG CONTROLLER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            size: 40,
                            onTap: () => controller.loginWithGoogle(
                              forceAccountPicker: true,
                            ),
                          ),
                          const SizedBox(width: 20),
                          SocialLoginButton(
                            icon: Icons.apple,
                            size: 30,
                            onTap: () {
                              Get.snackbar(
                                "Thông báo",
                                "Apple Sign-In sẽ được cập nhật sau",
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          SocialLoginButton(
                            icon: Icons.facebook,
                            size: 30,
                            onTap: () {
                              Get.snackbar(
                                "Thông báo",
                                "Facebook Sign-In sẽ được cập nhật sau",
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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
        ],
      ),
    );
  }
}

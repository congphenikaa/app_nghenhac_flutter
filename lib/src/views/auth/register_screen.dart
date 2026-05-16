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

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    final RxBool isPassHidden = true.obs;
    final RxBool isConfirmPassHidden = true.obs;

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.35,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'images/login.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: kSurfaceDark),
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
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
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

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
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
                              child: InkWell(
                                onTap: () => Get.toNamed(AppRoutes.LOGIN),
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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

                      CustomTextField(
                        controller: emailController,
                        hintText: "Email",
                        icon: Icons.mail_outline,
                      ),

                      const SizedBox(height: 15),

                      Obx(
                        () => CustomTextField(
                          controller: passController,
                          hintText: "Tạo mật khẩu",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isObscure: isPassHidden.value,
                          onToggleEye: () => isPassHidden.toggle(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Obx(
                        () => CustomTextField(
                          controller: confirmPassController,
                          hintText: "Xác nhận mật khẩu",
                          icon: Icons.lock_reset,
                          isPassword: true,
                          isObscure: isConfirmPassHidden.value,
                          onToggleEye: () => isConfirmPassHidden.toggle(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
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
                            controller.register(name, email, pass);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
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

                      const SizedBox(height: 25),

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

                      const SizedBox(height: 30),

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

          // LỚP OVERLAY LOADING MƯỢT MÀ
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: kBackgroundDark.withOpacity(0.95),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: kPrimaryColor,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Đang kết nối...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../view_models/auth_controller.dart';
import '../../widgets/common/custom_text_field.dart';
import 'widgets/avatar_picker_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();

  String selectedGender = 'other';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = authController.currentUser.value;
    if (user != null) {
      nameController.text = user.username;
      if (['male', 'female', 'other'].contains(user.gender)) {
        selectedGender = user.gender;
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn ảnh: $e");
    }
  }

  Future<void> _handleSave() async {
    FocusManager.instance.primaryFocus?.unfocus();

    bool success = await authController.updateProfile(
      name: nameController.text.trim(),
      gender: selectedGender,
      imageFile: _selectedImage,
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  ImageProvider _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    final user = authController.currentUser.value;
    if (user != null && user.avatar.isNotEmpty) {
      return CachedNetworkImageProvider(user.avatar);
    }
    return const CachedNetworkImageProvider("https://i.pravatar.cc/150?img=11");
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: "",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: authController.isLoading.value ? null : _handleSave,
              child: authController.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF30e87a),
                      ),
                    )
                  : const Text(
                      "Lưu",
                      style: TextStyle(
                        color: Color(0xFF30e87a),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AvatarPickerWidget(
              imageProvider: _getAvatarImage(),
              onPickImage: _pickImage,
            ),
            const SizedBox(height: 40),
            _buildLabeledTextField("Tên hiển thị", nameController),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Giới tính",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2E24), // Match CustomTextField
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGender,
                      dropdownColor: const Color(0xFF1D2E24),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF9DB8A8),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text("Nam")),
                        DropdownMenuItem(value: 'female', child: Text("Nữ")),
                        DropdownMenuItem(value: 'other', child: Text("Khác")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedGender = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

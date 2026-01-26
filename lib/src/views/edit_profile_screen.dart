import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_models/auth_controller.dart';

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
        // [TỐI ƯU QUAN TRỌNG CHO ĐIỆN THOẠI THẬT]
        // Nén ảnh để upload nhanh hơn và tránh lỗi server từ chối file quá lớn
        imageQuality: 80,
        maxWidth: 1024, // Giới hạn chiều rộng ảnh (Avatar không cần 4K)
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
    // 1. Ẩn bàn phím để tránh xung đột UI
    FocusManager.instance.primaryFocus?.unfocus();

    // 2. Gọi API cập nhật thông qua Controller
    // Controller sẽ tự hiển thị Snackbar (Thành công/Thất bại)
    bool success = await authController.updateProfile(
      name: nameController.text.trim(),
      gender: selectedGender,
      imageFile: _selectedImage,
    );

    // 3. Nếu thành công -> Đóng màn hình
    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
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
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF30e87a),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _getAvatarImage(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF30e87a),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Chạm để đổi ảnh",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),
            _buildTextField("Tên hiển thị", nameController),
            const SizedBox(height: 24),
            // ... (Phần Dropdown Giới tính giữ nguyên như code trước) ...
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Giới tính",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGender,
                      dropdownColor: Colors.grey[900],
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFF30e87a),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30e87a)),
            ),
          ),
        ),
      ],
    );
  }
}

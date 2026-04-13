import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../view_models/library_controller.dart';

class AddEditPlaylistScreen extends StatefulWidget {
  final String? playlistId;
  final String? initialName;
  final String? initialDesc;
  final String? initialImageUrl;

  const AddEditPlaylistScreen({
    super.key,
    this.playlistId,
    this.initialName,
    this.initialDesc,
    this.initialImageUrl,
  });

  @override
  State<AddEditPlaylistScreen> createState() => _AddEditPlaylistScreenState();
}

class _AddEditPlaylistScreenState extends State<AddEditPlaylistScreen> {
  final LibraryController libraryController = Get.find<LibraryController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.playlistId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameController.text = widget.initialName ?? '';
      descController.text = widget.initialDesc ?? '';
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

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Vui lòng nhập tên playlist",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    bool success = false;

    if (isEditing) {
      success = await libraryController.updatePlaylist(
        widget.playlistId!,
        nameController.text.trim(),
        descController.text.trim(),
        _selectedImage,
      );
    } else {
      success = await libraryController.createPlaylist(
        nameController.text.trim(),
        descController.text.trim(),
        imageFile: _selectedImage,
      );
    }

    if (success) {
      if (mounted) {
        Navigator.of(context).pop(true); // Trả về true báo hiệu cập nhật xong
      }
    }
  }

  ImageProvider _getPlaylistImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (isEditing &&
        widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(widget.initialImageUrl!);
    }
    // Ảnh mặc định
    return const CachedNetworkImageProvider(
      "https://phunugioi.com/wp-content/uploads/2022/03/Nhung-hinh-anh-dep-ve-am-nhac.jpg",
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing ? "Chỉnh sửa Playlist" : "Tạo Playlist mới",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: libraryController.isLoading.value ? null : _handleSave,
              child: libraryController.isLoading.value
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
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF30e87a),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: _getPlaylistImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30e87a),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
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
            const SizedBox(height: 16),
            const Text(
              "Chạm để chọn ảnh bìa",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 40),
            _buildTextField("Tên playlist", nameController),
            const SizedBox(height: 24),
            _buildTextField(
              "Mô tả (không bắt buộc)",
              descController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

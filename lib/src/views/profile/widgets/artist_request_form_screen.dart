import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:app_nghenhac/src/view_models/artist_request_controller.dart';
import 'package:app_nghenhac/src/view_models/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtistRequestFormScreen extends StatefulWidget {
  const ArtistRequestFormScreen({super.key});

  @override
  State<ArtistRequestFormScreen> createState() =>
      _ArtistRequestFormScreenState();
}

class _ArtistRequestFormScreenState extends State<ArtistRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final artistNameController = TextEditingController();
  final bioController = TextEditingController();
  final reasonController = TextEditingController();
  final instagramController = TextEditingController();
  final youtubeController = TextEditingController();
  final tiktokController = TextEditingController();

  final List<String> selectedGenres = [];

  final ArtistRequestController requestController =
      Get.find<ArtistRequestController>();
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  void initState() {
    super.initState();
    categoryController.fetchCategories(); // Load thể loại từ server
  }

  void toggleGenre(String genre) {
    setState(() {
      selectedGenres.contains(genre)
          ? selectedGenres.remove(genre)
          : selectedGenres.add(genre);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await requestController.submitRequest(
      artistName: artistNameController.text.trim(),
      bio: bioController.text.trim(),
      reason: reasonController.text.trim(),
      genre: selectedGenres,
      socialLinks: {
        'instagram': instagramController.text.trim(),
        'youtube': youtubeController.text.trim(),
        'tiktok': tiktokController.text.trim(),
      },
    );

    if (success) {
      Get.offNamed(AppRoutes.ARTIST_REQUEST_STATUS);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Đề xuất trở thành Artist"),
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = categoryController.categories;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: artistNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Tên nghệ sĩ *"),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Vui lòng nhập tên nghệ sĩ"
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Giới thiệu ngắn",
                  ),
                ),
                const SizedBox(height: 16),

                // === THỂ LOẠI ĐỘNG ===
                const Text(
                  "Thể loại nhạc (chọn nhiều)",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedGenres.contains(cat.name);
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) => toggleGenre(cat.name),
                      selectedColor: const Color(0xFF30e87a),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Mạng xã hội (tùy chọn)",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: instagramController,
                  decoration: const InputDecoration(labelText: "Instagram"),
                ),
                TextFormField(
                  controller: youtubeController,
                  decoration: const InputDecoration(labelText: "YouTube"),
                ),
                TextFormField(
                  controller: tiktokController,
                  decoration: const InputDecoration(labelText: "TikTok"),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: reasonController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Lý do bạn muốn trở thành Artist?",
                  ),
                ),
                const SizedBox(height: 40),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: requestController.isLoading.value
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30e87a),
                      ),
                      child: requestController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Gửi đơn đề xuất",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/search_controller.dart';

class SearchBarWidget extends StatelessWidget {
  final SearchPageController controller;

  const SearchBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tìm kiếm",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.textController,
            onChanged: (val) => controller.onSearchChanged(val),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Bạn muốn nghe gì?',
              hintStyle: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[800],
                size: 28,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Obx(
                () => controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          controller.textController.clear();
                          controller.onSearchChanged("");
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

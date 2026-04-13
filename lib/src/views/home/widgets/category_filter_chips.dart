import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/home_controller.dart';

class CategoryFilterChips extends StatelessWidget {
  final HomeController controller;

  const CategoryFilterChips({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        if (controller.categories.isEmpty) return const SizedBox();
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return Obx(() {
              final isSelected = controller.selectedCategoryIndex.value == index;
              return GestureDetector(
                onTap: () => controller.onCategorySelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C2E24) : Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }
}

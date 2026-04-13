import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerHeader extends StatelessWidget {
  final VoidCallback onShowOptions;

  const PlayerHeader({
    super.key,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        const Column(
          children: [
            Text(
              "ĐANG PHÁT",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            Text(
              "Danh sách phát",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: onShowOptions,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Area
              _buildHeader(),

              const SizedBox(height: 30),

              // 2. Value Proposition (Tại sao nên mua?)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tại sao nên dùng Premium?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      Icons.block,
                      "Nghe nhạc không quảng cáo",
                      "Tận hưởng âm nhạc không gián đoạn.",
                    ),
                    _buildFeatureItem(
                      Icons.download_for_offline,
                      "Tải xuống nhạc",
                      "Nghe mọi lúc mọi nơi, không cần mạng.",
                    ),
                    _buildFeatureItem(
                      Icons.skip_next,
                      "Bỏ qua không giới hạn",
                      "Chỉ cần nhấn Next để qua bài bạn không thích.",
                    ),
                    _buildFeatureItem(
                      Icons.high_quality,
                      "Chất lượng âm thanh cao",
                      "Cảm nhận từng nhịp bass sống động.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. Plan Card (Thẻ gói cước)
              _buildPlanCard(),

              const SizedBox(height: 40),

              // 4. Footer info
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Điều khoản và điều kiện áp dụng. Ưu đãi chỉ dành cho người dùng chưa từng dùng Premium.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 120), // Padding bottom for navigation bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[900]!, Colors.black],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Nhận 1 tháng Premium miễn phí",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF112117), // Dark green background
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF30e87a)),
            ),
            child: const Text(
              "Gói hiện tại: Free",
              style: TextStyle(
                color: Color(0xFF30e87a),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF30e87a), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2E24), Color(0xFF112117)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Premium Individual",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF30e87a),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "FREE TRIAL",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Miễn phí 1 tháng đầu\n59.000đ/tháng sau đó",
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            "• Nghe nhạc không quảng cáo\n• Tải xuống nghe offline\n• Chất lượng âm thanh cao nhất",
            style: TextStyle(color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  "Thành công",
                  "Chức năng thanh toán đang phát triển",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "DÙNG THỬ MIỄN PHÍ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

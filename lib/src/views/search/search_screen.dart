import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/player_controller.dart';
import '../../view_models/search_controller.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/search_category_grid.dart';
import 'widgets/search_results_list.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = Get.put(SearchPageController());
    final PlayerController playerController = Get.find();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBarWidget(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (controller.searchText.value.isEmpty) {
                  return SearchCategoryGrid(controller: controller);
                }

                return SearchResultsList(
                  controller: controller,
                  playerController: playerController,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

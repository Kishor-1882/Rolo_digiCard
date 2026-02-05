import 'package:get/get.dart';

class SavedItemsController extends GetxController {
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
}

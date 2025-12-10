import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:new_app/services/api_service.dart';
import 'package:country/country.dart';

class NewController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<dynamic> articles = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString category = ''.obs;
  final Rx<Country> country = Countries.values
      .firstWhere((c) => c.alpha2 == 'US')
      .obs;

  @override
  void onInit() {
    super.onInit();

    initializeController();
  }

  void initializeController() {
    category.value = 'general';
    fetchArticles(category.value);
  }

  void updateCategory(String newCategory) {
    category.value = newCategory;
    fetchArticles(newCategory);
  }

  Future<void> fetchArticles(String category) async {
    try {
      isLoading.value = true;

      final fetchedArticles = await _apiService.getAllArticles(category);

      articles.value = fetchedArticles;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshArticles() async {
    fetchArticles(category.value);
    // print('Articles refreshed for category: ${category.value}');
  }

  Future<void> searchArticles(String query) async {
    try {
      isLoading.value = true;
      final fetchedArticles = await _apiService.search(query);
      articles.value = fetchedArticles;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchArticlesByCategory(String category) async {
    try {
      isLoading.value = true;
      final fetchedArticles = await _apiService.getAllArticles(category);
      articles.value = fetchedArticles;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

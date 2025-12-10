import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/services/api_service.dart';
import 'package:new_app/services/hive_service.dart';
import 'package:country/country.dart';

class NewController extends GetxController {
  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();

  final RxList<Article> articles = <Article>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString category = 'general'.obs;
  final Rx<Country> country = Countries.values
      .firstWhere((c) => c.alpha2 == 'US')
      .obs;
  final RxBool isOnline = true.obs;
  final RxBool usingCachedData = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize immediately with cached data
    _initializeWithCache();

    // Then check connectivity and fetch fresh data
    _checkConnectivityAndFetch();
  }

  void _initializeWithCache() {
    try {
      // Try to load cached data immediately
      final cachedArticles = HiveService.getArticlesForCategory(category.value);

      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading cached data: $e';
      isLoading.value = false;
    }
  }

  Future<void> _checkConnectivityAndFetch() async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      isOnline.value = connectivityResult != ConnectivityResult.none;

      // If online, fetch fresh data
      if (isOnline.value) {
        await fetchArticles(category.value);
      } else if (articles.isEmpty) {
        // If offline and no cached data, show error
        errorMessage.value =
            'No internet connection and no cached data available.';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: $e';
      isLoading.value = false;
    }
  }

  void initializeController() {
    category.value = 'general';
    fetchArticles(category.value);
  }

  void updateCategory(String newCategory) {
    if (category.value != newCategory) {
      category.value = newCategory;

      // First try to load from cache
      final cachedArticles = HiveService.getArticlesForCategory(newCategory);
      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
      }

      // Then try to fetch fresh data if online
      if (isOnline.value) {
        fetchArticles(newCategory);
      }
    }
  }

  Future<void> fetchArticles(String category) async {
    try {
      if (!isLoading.value) isLoading.value = true;
      errorMessage.value = '';
      usingCachedData.value = false;

      final fetchedArticles = await _apiService.getAllArticles(category);

      // Update articles
      articles.value = fetchedArticles;

      // If we got data from API (not cache), update usingCachedData
      if (fetchedArticles.isNotEmpty &&
          HiveService.shouldRefreshCache(category)) {
        usingCachedData.value = false;
      }

      // Clear error if successful
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to fetch articles: ${e.toString()}';

      // If error, check if we have cached data
      if (articles.isEmpty) {
        final cachedArticles = HiveService.getArticlesForCategory(category);
        if (cachedArticles.isNotEmpty) {
          articles.value = cachedArticles;
          usingCachedData.value = true;
          errorMessage.value = 'No internet. Showing cached data.';
        }
      }

      // Show snackbar only for online errors with no cached fallback
      if (isOnline.value && !usingCachedData.value) {
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshArticles() async {
    await fetchArticles(category.value);
  }

  Future<void> searchArticles(String query) async {
    try {
      if (query.isEmpty) {
        await fetchArticles(category.value);
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';
      usingCachedData.value = false;

      final searchResults = await _apiService.search(query);

      articles.value = searchResults;
    } catch (e) {
      errorMessage.value = 'Failed to fetch articles: ${e.toString()}';

      Get.snackbar(
        'Search Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get cache status
  String getCacheStatus() {
    if (usingCachedData.value) {
      final lastFetch = HiveService.getLastFetchTime(category.value);
      if (lastFetch != null) {
        final difference = DateTime.now().difference(lastFetch);
        final hours = difference.inHours;
        if (hours > 0) {
          return 'No internet (${hours}h ago)';
        } else {
          return 'No internet (${difference.inMinutes}m ago)';
        }
      }
      return 'No internet';
    }
    return 'Live data';
  }
}

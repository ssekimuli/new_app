import 'dart:async';

import 'package:flutter/material.dart';
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
  final Rx<DateTime> lastOnlineTime = DateTime.now().obs;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();

    // Initialize immediately with cached data
    _initializeWithCache();

    // Then check connectivity and fetch fresh data
    _checkConnectivityAndFetch();
    
    // Start listening to connectivity changes
    _startConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final bool wasOnline = isOnline.value;
        final bool nowOnline = result != ConnectivityResult.none;
        
        isOnline.value = nowOnline;
        
        // Handle connectivity changes
        if (nowOnline && !wasOnline) {
          _onInternetRestored();
        } else if (!nowOnline && wasOnline) {
          _onInternetLost();
        }
      },
    );
  }

  void _onInternetRestored() {
    lastOnlineTime.value = DateTime.now();
    
    // Show notification
  
    Get.rawSnackbar(
          message: 'Internet Restored',
          backgroundColor: Colors.green,
          borderRadius: 10,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        );
    
    // Auto-refresh current category
    if (!isLoading.value) {
      _fetchFreshDataSilently();
    }
    
    // Trigger UI update
    update();
  }

  void _onInternetLost() {
    usingCachedData.value = true;
    errorMessage.value = 'You are offline';
    // Show subtle notification
        Get.rawSnackbar(
          message: 'Internet Lost',
          backgroundColor: Colors.orange,
          borderRadius: 10,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        );
  }

  void _initializeWithCache() {
    try {
      final cachedArticles = HiveService.getArticlesForCategory(category.value);
      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
        isLoading.value = false;
      }
    } catch (e) {
      print('Cache load error: $e');
    }
  }

  Future<void> _checkConnectivityAndFetch() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      isOnline.value = connectivityResult != ConnectivityResult.none;
      lastOnlineTime.value = DateTime.now();

      if (isOnline.value) {
        await fetchArticles(category.value);
      } else if (articles.isEmpty) {
        // Load from cache if no articles yet
        final cachedArticles = HiveService.getArticlesForCategory(category.value);
        if (cachedArticles.isNotEmpty) {
          articles.value = cachedArticles;
          usingCachedData.value = true;
        }
        errorMessage.value = 'No internet connection. Using cached data.';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error: $e';
      isLoading.value = false;
    }
  }

  // Silently fetch fresh data without loading indicators
  Future<void> _fetchFreshDataSilently() async {
    try {
      usingCachedData.value = false;
      
      final fetchedArticles = await _apiService.getAllArticles(category.value);
      
      if (fetchedArticles.isNotEmpty) {
        articles.value = fetchedArticles;
        
        // Show subtle notification
        Get.rawSnackbar(
          message: 'Articles updated',
          backgroundColor: Colors.green,
          borderRadius: 10,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
        );
      }
    } catch (e) {
      print('Silent refresh failed: $e');
      // Don't show error in silent mode
    }
  }

  void initializeController() {
    category.value = 'general';
    fetchArticles(category.value);
  }

  void updateCategory(String newCategory) {
    if (category.value != newCategory) {
      category.value = newCategory;

      // Load from cache immediately
      final cachedArticles = HiveService.getArticlesForCategory(newCategory);
      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
      }

      // Fetch fresh data if online
      if (isOnline.value) {
        fetchArticles(newCategory);
      } else {
        isLoading.value = false;
        errorMessage.value = 'No internet. Showing cached data.';
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

      // Update cache status
      if (fetchedArticles.isNotEmpty) {
        usingCachedData.value = false;
        errorMessage.value = '';
      } else {
        // If API returns empty, fall back to cache
        final cachedArticles = HiveService.getArticlesForCategory(category);
        if (cachedArticles.isNotEmpty) {
          articles.value = cachedArticles;
          usingCachedData.value = true;
          errorMessage.value = 'No new articles. Showing cached data.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch articles: ${e.toString()}';
      
      // Fallback to cache on error
      final cachedArticles = HiveService.getArticlesForCategory(category);
      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
        errorMessage.value = 'Network error. Showing cached data.';
      }

      // Only show snackbar for online errors
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
      update(); // Ensure UI rebuilds
    }
  }

  Future<void> refreshArticles() async {
    if (isOnline.value) {
      await fetchArticles(category.value);
    } else {
      // When offline, just reload from cache
      final cachedArticles = HiveService.getArticlesForCategory(category.value);
      if (cachedArticles.isNotEmpty) {
        articles.value = cachedArticles;
        usingCachedData.value = true;
        Get.snackbar(
          'Offline Mode',
          'Showing cached articles',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    }
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

      if (isOnline.value) {
        final searchResults = await _apiService.search(query);
        articles.value = searchResults;
      } else {
        // Offline search - filter cached articles
        final cachedArticles = HiveService.getArticlesForCategory(category.value);
        final filteredArticles = cachedArticles.where((article) {
          return article.title.toLowerCase().contains(query.toLowerCase()) ||
                 (article.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
        
        articles.value = filteredArticles;
        usingCachedData.value = true;
        
        if (filteredArticles.isEmpty) {
          errorMessage.value = 'No results found in cached data.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to search: ${e.toString()}';
      Get.snackbar(
        'Search Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get cache status with time
  String getCacheStatus() {
    if (usingCachedData.value) {
      final lastFetch = HiveService.getLastFetchTime(category.value);
      if (lastFetch != null) {
        final difference = DateTime.now().difference(lastFetch);
        if (difference.inHours > 0) {
          return 'Cached (${difference.inHours}h ago)';
        } else if (difference.inMinutes > 0) {
          return 'Cached (${difference.inMinutes}m ago)';
        } else {
          return 'Cached (just now)';
        }
      }
      return 'Cached';
    }
    return 'Live';
  }

  // Get connection status text
  String getConnectionStatus() {
    if (isOnline.value) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  // Manual connectivity check
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      isOnline.value = result != ConnectivityResult.none;
      
      if (isOnline.value) {
        await fetchArticles(category.value);
      }
    } catch (e) {
      print('Connectivity check error: $e');
    }
  }
}
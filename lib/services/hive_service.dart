import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_app/constants/storage_key.dart';
import 'package:path_provider/path_provider.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/models/category.dart';

class HiveService {
  static const String apiKeyBox = 'appKey';
  static const String articlesBox = 'articles_box';
  static const String categoriesBox = 'categories_box';
  static const String cacheTimestampBox = 'cache_timestamps';
  
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive with Flutter
      await Hive.initFlutter();
      
      // Register adapters
      Hive.registerAdapter(ArticleAdapter());
      Hive.registerAdapter(CategoryAdapter());
      
      // Open all boxes with correct types during initialization
      await _openAllBoxesWithTypes();
      
      print('✅ Hive initialized successfully');
      _isInitialized = true;
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  static Future<void> _openAllBoxesWithTypes() async {
    print('📦 Opening all boxes with correct types...');
    
    // Open each box with explicit type
    try {
      // apiKeyBox as Box<String>
      await Hive.openBox<String>(apiKeyBox);
      
      // Initialize API key if not present
      final keyBox = Hive.box<String>(apiKeyBox);
      if (!keyBox.containsKey('apiKey') || keyBox.get('apiKey') == null) {
        await keyBox.put('apiKey', StorageKeys.apiKey);
        print('🔑 API Key stored in Hive: ${StorageKeys.apiKey}');
      } else {
        print('🔑 API Key already exists in Hive');
      }
      
      print('  ✅ $apiKeyBox opened as Box<String>');
    } catch (e) {
      print('  ⚠️  Error opening $apiKeyBox: $e');
    }
    
    try {
      await Hive.openBox<Article>(articlesBox);
      print('  ✅ $articlesBox opened as Box<Article>');
    } catch (e) {
      print('  ⚠️  Error opening $articlesBox: $e');
    }
    
    try {
      await Hive.openBox<Category>(categoriesBox);
      print('  ✅ $categoriesBox opened as Box<Category>');
    } catch (e) {
      print('  ⚠️  Error opening $categoriesBox: $e');
    }
    
    try {
      await Hive.openBox<DateTime>(cacheTimestampBox);
      print('  ✅ $cacheTimestampBox opened as Box<DateTime>');
    } catch (e) {
      print('  ⚠️  Error opening $cacheTimestampBox: $e');
    }
  }

  // Get box reference - synchronous now since boxes are opened at init
  static Box<T> _getBox<T>(String boxName) {
    if (!_isInitialized) {
      throw Exception('Hive not initialized. Call HiveService.init() first.');
    }
    
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open');
    }
    
    final box = Hive.box<T>(boxName);
    return box;
  }

  // API Key Management - Synchronous methods
  static void saveApiKey(String apiKey) {
    final box = _getBox<String>(apiKeyBox);
    box.put('apiKey', apiKey);
    print('🔑 API Key updated in Hive');
  }

  static String? getApiKey() {
    try {
      final box = _getBox<String>(apiKeyBox);
      final apiKey = box.get('apiKey');
      
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️  Warning: API Key not found in Hive');
        return null;
      }
      
      return apiKey;
    } catch (e) {
      print('❌ Error getting API key: $e');
      return null;
    }
  }

  static bool hasApiKey() {
    final apiKey = getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // Article Management - Synchronous methods
  static Box<Article> getArticlesBox() {
    return _getBox<Article>(articlesBox);
  }

  static void saveArticlesForCategory(String category, List<Article> articles) {
    final box = getArticlesBox();
    
    // Get all keys for this category
    final keysToDelete = <dynamic>[];
    for (final key in box.keys) {
      final article = box.get(key);
      if (article != null && article.category == category) {
        keysToDelete.add(key);
      }
    }
    
    // Delete old articles
    for (final key in keysToDelete) {
      box.delete(key);
    }
    
    // Save new articles with timestamp-based keys
    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < articles.length; i++) {
      final article = articles[i];
      final key = '${category}_${now}_$i';
      box.put(key, article);
    }
    
    // Update cache timestamp
    _updateCacheTimestamp(category);
    
    print('💾 Saved ${articles.length} articles for category: $category');
  }

  static void _updateCacheTimestamp(String category) {
    final timestampBox = _getBox<DateTime>(cacheTimestampBox);
    timestampBox.put(category, DateTime.now());
  }

  static List<Article> getArticlesForCategory(String category) {
    final box = getArticlesBox();
    final articles = box.values
        .where((article) => article.category == category)
        .toList();
    
    print('📚 Retrieved ${articles.length} cached articles for category: $category');
    return articles;
  }

  static DateTime? getLastFetchTime(String category) {
    final timestampBox = _getBox<DateTime>(cacheTimestampBox);
    return timestampBox.get(category);
  }

  static bool shouldRefreshCache(String category, {Duration maxAge = const Duration(hours: 1)}) {
    final lastFetch = getLastFetchTime(category);
    if (lastFetch == null) {
      print('🔄 No cache found for category: $category - should refresh');
      return true;
    }
    
    final now = DateTime.now();
    final shouldRefresh = now.difference(lastFetch) > maxAge;
    
    if (shouldRefresh) {
      print('🔄 Cache expired for category: $category. Last fetched: $lastFetch');
    } else {
      print('💾 Using cached data for category: $category. Last fetched: $lastFetch');
    }
    
    return shouldRefresh;
  }

  static void clearCategoryCache(String category) {
    final box = getArticlesBox();
    final keysToDelete = <dynamic>[];
    
    for (final key in box.keys) {
      final article = box.get(key);
      if (article != null && article.category == category) {
        keysToDelete.add(key);
      }
    }
    
    for (final key in keysToDelete) {
      box.delete(key);
    }
    
    final timestampBox = _getBox<DateTime>(cacheTimestampBox);
    timestampBox.delete(category);
    
    print('🗑️  Cleared cache for category: $category (${keysToDelete.length} articles)');
  }

  // Category Management
  static Box<Category> getCategoriesBox() {
    return _getBox<Category>(categoriesBox);
  }

  static List<Category> getCategories() {
    final box = getCategoriesBox();
    final categories = box.values.toList();
    print('📁 Retrieved ${categories.length} categories from cache');
    return categories;
  }

  static void saveAllCategories(List<Category> categories) {
    final box = getCategoriesBox();
    box.clear();
    
    for (final category in categories) {
      box.put(category.name, category);
    }
    
    print('📁 Saved ${categories.length} categories to cache');
  }

  // Utility Methods
  static void checkHiveStatus() {
    print('🔍 Hive Status Check:');
    print('  - Is initialized: $_isInitialized');
    print('  - Is $apiKeyBox open: ${Hive.isBoxOpen(apiKeyBox)}');
    print('  - Is $articlesBox open: ${Hive.isBoxOpen(articlesBox)}');
    print('  - Is $categoriesBox open: ${Hive.isBoxOpen(categoriesBox)}');
    print('  - Is $cacheTimestampBox open: ${Hive.isBoxOpen(cacheTimestampBox)}');
  }

  // Close all boxes
  static Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      _isInitialized = false;
      print('🔒 All Hive boxes closed');
    } catch (e) {
      print('❌ Error closing Hive boxes: $e');
    }
  }
}
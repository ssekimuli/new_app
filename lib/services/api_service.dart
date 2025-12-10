import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_app/constants/news_app_api.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/services/hive_service.dart';

class ApiService {
  
  Future<List<Article>> getAllArticles(String category) async {
    
    
    try {
      // Check cache first (1 hour expiry)
      if (!HiveService.shouldRefreshCache(category)) {
        final cachedArticles = HiveService.getArticlesForCategory(category);
        if (cachedArticles.isNotEmpty) {

          return cachedArticles;
        }
      }

      // Get API key from Hive
      final key = HiveService.getApiKey();

      if (key == null || key.isEmpty) {
        throw Exception('API key not found in Hive storage');
      }

      final uri = Uri.parse('${NewsAppApi.allArticleApi}$category&apiKey=$key');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> articles = jsonResponse['articles'] ?? [];
        
        if (articles.isEmpty) {
          // Return cached articles if available
          final cachedArticles = HiveService.getArticlesForCategory(category);
          return cachedArticles;
        }

        // Convert to Article models
        final List<Article> articleList = articles
            .where((article) => article['title'] != null)
            .map((articleJson) => Article.fromJson(articleJson, category))
            .toList();

        
        // Save to cache
        HiveService.saveArticlesForCategory(category, articleList);

        return articleList;
      } else {

        // If API fails, return cached data if available
        final cachedArticles = HiveService.getArticlesForCategory(category);
        if (cachedArticles.isNotEmpty) {

          return cachedArticles;
        }
        
        throw Exception(
          'Failed to load articles. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      
      
      // If any error occurs, try to return cached data
      final cachedArticles = HiveService.getArticlesForCategory(category);
      if (cachedArticles.isNotEmpty) {
        return cachedArticles;
      }
      
      rethrow;
    }
  }

  Future<List<Article>> search(String searchQuery) async {
    try {
      // Use HiveService to get API key
      final key = HiveService.getApiKey();

      if (key == null || key.isEmpty) {
        throw Exception('API key not found in Hive storage');
      }

      final uri = Uri.parse(
        '${NewsAppApi.allArticleApi}$searchQuery&apiKey=$key',
      );


      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> articles = jsonResponse['articles'] ?? [];
        
        
        // Convert to Article models with 'search' as category
        return articles
            .where((article) => article['title'] != null)
            .map((articleJson) => Article.fromJson(articleJson, 'search'))
            .toList();
      } else {
        throw Exception(
          'Failed to load search results. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in search for "$searchQuery": $e');
      rethrow;
    }
  }
}
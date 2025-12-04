import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:new_app/constants/news_app_api.dart';

class ApiService {
  get url => null;

  Future<List<dynamic>> getAllArticles(String category) async {
    try {
      final appKeyBox = await Hive.openBox('appKey');
      final key = appKeyBox.get('apiKey');

      if (key == null || key.toString().isEmpty) {
        throw Exception('API key not found in Hive storage');
      }

      final uri = Uri.parse('${NewsAppApi.allArticleApi}$category&apiKey=$key');
      

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final List<dynamic> articles = jsonResponse['articles'];
        return articles;
      } else {
        throw Exception(
          'Failed to load articles. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> search(String searchQuery) async {
    try {
      final appKeyBox = await Hive.openBox('appKey');
      final key = appKeyBox.get('apiKey');

      if (key == null || key.toString().isEmpty) {
        throw Exception('API key not found in Hive storage');
      }

      final uri = Uri.parse(
        '${NewsAppApi.allArticleApi}$searchQuery&apiKey=$key',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> articles = jsonResponse['articles'];

        // final List<String> titles = [];
        // for (var article in articles) {
        //   if (article is Map<String, dynamic> && article['title'] != null) {
        //     titles.add(article['title'].toString());
        //   }
        // }
        // return titles;
        return articles;
      } else {
        throw Exception(
          'Failed to load search results. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}


import 'package:new_app/constants/storage_key.dart';
import 'package:new_app/constants/storage_key.dart';
import 'package:new_app/models/Headline.dart';

class NewsAppApi{
  static const String baseURL = 'https://newsapi.org/v2/';
  static const headlineApi='${baseURL}top-headlines/sources?apiKey=${StorageKeys.apiKey}';
  static const allArticleApi ='${baseURL}everything?q';
  static const headlineByCategoryApi='${baseURL}top-headlines/sources?category=';
}
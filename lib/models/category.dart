import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime lastFetched;

  Category({required this.name, required this.lastFetched});

  factory Category.fromName(String categoryName) {
    // Map of API category names to display names
    final categoryMap = {
      'business': 'business',
      'entertainment': 'entertainment',
      'general': 'general',
      'health': 'health',
      'science': 'science',
      'sports': 'sports',
      'technology': 'technology',
    };

    return Category(
      name: categoryMap[categoryName] ?? categoryName,
      lastFetched: DateTime.now(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:new_app/services/api_service.dart';
import 'package:new_app/widgets/article_card.dart';

class ArticleCategoryScreen extends StatefulWidget {
  const ArticleCategoryScreen({super.key});

  @override
  State<ArticleCategoryScreen> createState() => _ArticleCategoryScreenState();
}

class _ArticleCategoryScreenState extends State<ArticleCategoryScreen>
    with SingleTickerProviderStateMixin {
  final List _categories = [
    {'label': 'All', 'value': 'general'},
    {'label': 'Headlines', 'value': 'headlines'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Entertainment', 'value': 'entertainment'},
    {'label': 'Health', 'value': 'health'},
    {'label': 'Science', 'value': 'science'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Technology', 'value': 'technology'},
  ];

  final List _articles = [];
  String _currentCategory = 'general';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentCategory = _categories[_tabController.index]['value'];
          _fetchArticles(_currentCategory);
        });
      }
    });
    _fetchArticles(_currentCategory);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles(String category) async {
    // Call the service function
    final articles = await ApiService().getAllArticles(category);

    setState(() {
      _articles.clear();
      _articles.addAll(articles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Column(
        children: [
          // TabBar
          TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            isScrollable: true,
            tabs: _categories
                .map((category) => Tab(text: category['label']))
                .toList(),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _articles.isEmpty
                ? Expanded(child: Text('No articles available'))
                : TabBarView(
                    controller: _tabController,
                    children: _articles.map((article) {
                      return ListView.separated(
                        itemCount: _articles.length,
                        padding: const EdgeInsets.all(8.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          return ArticleCard(
                            title: article['title'] ?? 'No Title',
                            description: article['description'],
                            source: article['source']['name'] ?? 'No source',
                            publishedAt: article['publishedAt'],
                            imageUrl:
                                article['urlToImage'] ??
                                'https://via.placeholder.com/150',
                            category: _currentCategory,
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

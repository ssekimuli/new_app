import 'package:flutter/material.dart';
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
    // Simulate fetching articles based on category
    // await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // _articles.clear();
      // for (int i = 1; i <= 10; i++) {
      // _articles = [];
      // }
      print('Fetching articles for category: $category');
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

          // TabBarView
          // Center(child: Text('No articles available'))
          Expanded(
            child: _articles.isEmpty
                ? Expanded(child: Text('No articles available'))
                : TabBarView(
                    controller: _tabController,
                    children: _articles.map((article) {
                      return ListView.builder(
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          return ArticleCard(
                            title:
                                'Watch: How Tim Davie addressed BBC controversies over the years',
                            description:
                                'The BBC\'s director general Tim Davie has resigned over Trump documentary edit.',
                            source: 'BBC News',
                            publishedAt: '2026-06-25',
                            imageUrl:
                                'https://ichef.bbci.co.uk/news/1024/branded_news/4c76/live/2a1de0a0-bda5-11f0-ae46-bd64331f0fd4.jpg',
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/controllers/new_controller.dart';
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

  late NewController newdata;

  late TabController _tabController;

  // String currentCategory = 'general';

  @override
  void initState() {
    super.initState();
    newdata = Get.put(NewController());
    String currentCategory = newdata.category.value;

    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {

          currentCategory = _categories[_tabController.index]['value'];
          newdata.updateCategory(currentCategory);

        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<NewController>();
    super.dispose();
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
            child: newdata.articles.isEmpty
                ? const Center(child: Text('No articles available'))
                : TabBarView(
                    controller: _tabController,
                    children: newdata.articles.map((article) {
                      return ListView.separated(
                        itemCount: newdata.articles.length,
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
                            category: newdata.category.value,
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

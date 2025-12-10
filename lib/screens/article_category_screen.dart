import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/controllers/new_controller.dart';
import 'package:new_app/models/articles.dart';
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

  late TabController _tabController;
  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize TabController
    _tabController = TabController(length: _categories.length, vsync: this);

    // Add tab change listener
    _tabController.addListener(() {
      // This handles both tapping and swiping
      if (_tabController.index != _previousTabIndex) {
        final newController = Get.find<NewController>();
        final currentCategory = _categories[_tabController.index]['value'];
        newController.updateCategory(currentCategory);
        _previousTabIndex = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the controller instance
    final NewController newController = Get.put(NewController());

    return Column(
      children: [
        // TabBar
        Container(
          color: const Color.fromARGB(255, 206, 203, 203),
          child: TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            isScrollable: true,
            tabs: _categories
                .map((category) => Tab(text: category['label']))
                .toList(),
          ),
        ),
        const SizedBox(height: 5),

        // update the UI when articles change
        Expanded(
          child: Obx(() {
            if (newController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (newController.articles.isEmpty) {
              return const Center(child: Text('No articles available'));
            }

            return TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return ListView.separated(
                  itemCount: newController.articles.length,
                  padding: const EdgeInsets.all(8.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return ArticleCard(
                      category: newController.category.value,
                      article: Articles.fromJson(newController.articles[index]),
                    );
                  },
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }
}

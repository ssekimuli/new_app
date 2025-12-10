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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth;

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
                return RefreshIndicator(
                  onRefresh: () async {
                    await newController.refreshArticles();
                  },
                  child: _buildLayout(
                    context,
                    screenWidth,
                    isPortrait,
                    newController,
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }
}

Widget _buildLayout(
  BuildContext context,
  double width,
  bool isPortrait,
  NewController controller,
) {
  // Mobile (0 - 599)
  if (width < 600) {
    return _buildListView(context, controller);
  }
  // Small tablet (600 - 899)
  else if (width < 900) {
    if (isPortrait) {
      return _buildGridView(context, 2, controller);
    } else {
      return _buildGridView(context, 3, controller);
    }
  }
  // Large tablet (900 - 1199)
  else if (width < 1200) {
    if (isPortrait) {
      return _buildGridView(context, 3, controller);
    } else {
      return _buildGridView(context, 4, controller);
    }
  }
  // Desktop (1200+)
  else {
    return _buildGridView(context, 5, controller);
  }
}

Widget _buildListView(BuildContext context, NewController controller) {
  return Scrollbar(
    thumbVisibility: true,
    trackVisibility: true,
    thickness: 4,
    radius: const Radius.circular(3),
    interactive: true,
    child: ListView.separated(
      itemCount: controller.articles.length,
      padding: const EdgeInsets.all(4.0),
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ArticleCard(
          category: controller.category.value,
          article: Article.fromJson(controller.articles[index], controller.category.value),
          isCompact: false,
        );
      },
    ),
  );
}

Widget _buildGridView(
  BuildContext context,
  int columns,
  NewController controller,
) {
  return Scrollbar(
    thumbVisibility: true,
    trackVisibility: true,
    thickness: 4,
    radius: const Radius.circular(3),
    interactive: true,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        mainAxisExtent: 320,
      ),
      itemCount: controller.articles.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 320,
          child: ArticleCard(
            category: controller.category.value,
            article: Article.fromJson(controller.articles[index], controller.category.value),
            isCompact: true,
          ),
        );
      },
    ),
  );
}

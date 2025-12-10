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

  late TabController _tabController;
  int _previousTabIndex = 0;
  late NewController _newController;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Initialize controller - SAFE APPROACH
    _initializeController();
  }

  void _initializeController() {
    try {
      // Try to find existing controller
      _newController = Get.find<NewController>();
      
    } catch (e) {
      // If not found, create it
      _newController = Get.put(NewController());
    }
    
    _controllerInitialized = true;
    
    // Set initial tab
    if (_previousTabIndex == 0) {
      final initialCategory = _categories[0]['value'];
      if (_newController.category.value != initialCategory) {
        _newController.updateCategory(initialCategory);
      }
    }
  }

  void _onTabChanged() {
    if (_tabController.index != _previousTabIndex && _controllerInitialized) {
      final currentCategory = _categories[_tabController.index]['value'];
      _newController.updateCategory(currentCategory);
      _previousTabIndex = _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!_controllerInitialized) {
      _initializeController();
    }

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
        
        // Cache status indicator
        Obx(() {
          if (_newController.usingCachedData.value) {
            return Container(
              color: Colors.amber[50],
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 14, color: Colors.amber[700]),
                  SizedBox(width: 4),
                  Text(
                    _newController.getCacheStatus(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox();
        }),
        
        const SizedBox(height: 5),

        // Articles List
        Expanded(
          child: Obx(() {
            // Show loading only if no cached data
            if (_newController.isLoading.value && _newController.articles.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading articles...'),
                  ],
                ),
              );
            }

            // Show cached data immediately, even if loading
            if (_newController.articles.isNotEmpty) {
              return _buildContent(context, screenWidth, isPortrait);
            }

            // Show error if no data at all
            if (_newController.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load articles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _newController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _newController.refreshArticles(),
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            // Default empty state
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No articles available'),
                  SizedBox(height: 8),
                  Text(
                    'Check your connection or try again',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, double width, bool isPortrait) {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((_) {
        return RefreshIndicator(
          onRefresh: () async {
            await _newController.refreshArticles();
          },
          child: _buildLayout(
            context,
            width,
            isPortrait,
            _newController,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    double width,
    bool isPortrait,
    NewController controller,
  ) {
    if (width < 600) {
      return _buildListView(context, controller);
    } else if (width < 900) {
      return _buildGridView(
        context,
        isPortrait ? 2 : 3,
        controller,
      );
    } else if (width < 1200) {
      return _buildGridView(
        context,
        isPortrait ? 3 : 4,
        controller,
      );
    } else {
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
          final article = controller.articles[index];
          return ArticleCard(
            category: controller.category.value,
            article: article,
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
          final article = controller.articles[index];
          return SizedBox(
            height: 320,
            child: ArticleCard(
              category: controller.category.value,
              article: article,
              isCompact: true,
            ),
          );
        },
      ),
    );
  }
}
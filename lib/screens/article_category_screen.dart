import 'package:flutter/material.dart';

class ArticleCategoryScreen extends StatefulWidget {
  const ArticleCategoryScreen({super.key});

  @override
  State<ArticleCategoryScreen> createState() => _ArticleCategoryScreenState();
}

class _ArticleCategoryScreenState extends State<ArticleCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 7, child:  TabBar(
      // padding: EdgeInsets.all(2),
      automaticIndicatorColorAdjustment: true,
      isScrollable: true,
      // unselectedLabelStyle: TextStyle(
      //   backgroundColor: Colors.black,
      //       color: Colors.white
      //
      // ),
      tabs: [
        Tab(
          text: 'All',

        ),
        Tab(
          text: 'Business',
        ),
        Tab(
          text: 'Entertainment',
        ),
        Tab(
          text: 'Health',
        ),
        Tab(
          text: 'Science',
        ),
        Tab(
          text: 'Sports',
        ),
        Tab(
          text: 'Technology',
        )
      ],
    )
    );
  }
}

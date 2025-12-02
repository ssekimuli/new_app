import 'package:flutter/material.dart';

import 'article_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                    size: 24,
                  ),
                // helperText: 'Search article',
                  hintText: "Search articles...",
                fillColor: Colors.grey[300],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                )
              ),
            ),
            SizedBox(height: 20),
            ArticleCategoryScreen()
          ],
        ),
      )
    );
  }
}

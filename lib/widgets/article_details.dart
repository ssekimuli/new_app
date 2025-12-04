import 'package:flutter/material.dart';
import 'package:new_app/models/articles.dart';

class ArticleDetails extends StatefulWidget {
  const ArticleDetails({
    super.key,
    required this.article,
  });

  final Articles article;

  @override
  State<ArticleDetails> createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails> {
  @override
  Widget build(BuildContext context) {
    // Access the article via widget.article
    final article = widget.article;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // You can expand this with more article details
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Add more article details here
            // For example: article.content, article.author, article.date, etc.
            if (article.content != null)
              Text(
                article.content!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
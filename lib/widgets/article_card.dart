import 'package:flutter/material.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/utils/date_utils.dart' as app_date_utils;
import 'package:new_app/widgets/article_details.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final String category;
  final bool isCompact;
  final double fontSizeFactor;

  const ArticleCard({
    super.key,
    required this.article,
    required this.category,
    required this.isCompact,
    this.fontSizeFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetails(article: article),
          ),
        ),
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              child: article.urlToImage == null || article.urlToImage!.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.newspaper,
                          color: Colors.grey,
                          size: 60,
                        ),
                      ),
                    )
                  : Image.network(
                      article.urlToImage!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.article,
                              color: Colors.grey,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 13 * fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  // Subtitle/Description
                  Text(
                    article.description ?? 'No description available',
                    style: TextStyle(
                      fontSize: 12 * fontSizeFactor,
                      color: Colors.grey,
                      height: 1.5 * fontSizeFactor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Footer with metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Source/Time
                      Text(
                        '${article.source} • ${app_date_utils.DateUtils.formatPublishedDate(article.publishedAt.toString())}',
                        style: TextStyle(
                          fontSize: 12 * fontSizeFactor,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/utils/date_utils.dart' as app_date_utils;
import 'package:shimmer/shimmer.dart';

class ArticleDetails extends StatefulWidget {
  const ArticleDetails({super.key, required this.article});

  final Articles article;

  @override
  State<ArticleDetails> createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails> {
  bool _isImageError = false;

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.category.isNotEmpty 
              ? article.category 
              : 'Article Details',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(article),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              article.title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Article Metadata
            _buildArticleMetadata(context, article),
            
            const SizedBox(height: 16),
            
            // Content
            if (article.content != null && article.content!.isNotEmpty)
              Text(
                article.content!,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              )
            else
              _buildPlaceholderContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Articles article) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: article.urlToImage != null && article.urlToImage!.isNotEmpty && !_isImageError
            ? Image.network(
                article.urlToImage!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildShimmerPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isImageError = true;
                      });
                    }
                  });
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildArticleMetadata(BuildContext context, Articles article) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author and Source
        if (article.author != null && article.author!.isNotEmpty)
          Text(
            'By ${article.author!}',
            style: textTheme.bodyMedium?.copyWith(
              color: textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        
        const SizedBox(height: 4),
        
        // Source and Date
        Row(
          children: [
            if (article.source != null && article.source!.isNotEmpty)
              Expanded(
                child: Text(
                  'Source: ${article.source!}',
                  style: textTheme.bodySmall?.copyWith(
                    color: textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            const SizedBox(width: 8),
            
            if (article.publishedAt != null)
              Text(
                app_date_utils.DateUtils.formatPublishedDate(article.publishedAt),
                style: textTheme.bodySmall?.copyWith(
                  color: textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      children: [
        _buildTextShimmer(width: double.infinity),
        const SizedBox(height: 8),
        _buildTextShimmer(width: double.infinity),
        const SizedBox(height: 8),
        _buildTextShimmer(width: MediaQuery.of(context).size.width * 0.8),
      ],
    );
  }

  Widget _buildTextShimmer({double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 16,
        width: width,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        color: Colors.white,
      ),
    );
  }

}
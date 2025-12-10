import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_app/models/articles.dart';
import 'package:new_app/services/api_service.dart';
import 'package:new_app/widgets/article_details.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults({super.key, required this.searchQuery});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _debouncedSearch();
  }

  @override
  void didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != oldWidget.searchQuery) {
      _debouncedSearch();
    }
  }

  void _debouncedSearch() {
    _debounceTimer?.cancel();

    if (widget.searchQuery.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    if (widget.searchQuery.length < 3) {
      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (widget.searchQuery.isEmpty || widget.searchQuery.length < 3) return;

    try {
      final results = await ApiService().search(widget.searchQuery);

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
          _results = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Wait a moment and try again',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (_results.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: _results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                (_results[index] as Map<String, dynamic>)['title']
                        ?.toString() ??
                    'No title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                ),
              ),
            ),
            trailing: const Icon(Icons.search, color: Colors.grey),
            visualDensity: const VisualDensity(vertical: -2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetails(
                    article: Article.fromJson(_results[index], 'search'),
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          );
        },
      );
    }

    // If no results
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          widget.searchQuery.isEmpty
              ? 'Enter a search term'
              : 'No results found for "${widget.searchQuery}"',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

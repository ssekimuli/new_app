import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_app/services/api_service.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults({super.key, required this.searchQuery});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<String> _results = [];
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
    if (widget.searchQuery.isEmpty) return;

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
            'Error: $_errorMessage',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (_results.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_results[index]),
            onTap: () {
              // Handle item tap
              print('Selected: ${_results[index]}');
            },
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

import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final String searchQuery;
  final List<String> results;

  const SearchResults({
    super.key, 
    required this.searchQuery,
    this.results = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (results.isNotEmpty) {
      return ListView(
        shrinkWrap: true,
        children: results.map((result) {
          return ListTile(
            title: Text(result),
            subtitle: Text('Searching for: $searchQuery'),
            onTap: () {
            },
          );
        }).toList(),
      );
    }
    
    // If no results, show empty state
    return Center(
      child: Text('No results found for "$searchQuery"'),
    );
  }
}
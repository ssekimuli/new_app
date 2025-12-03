import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final String title;

  const SearchResults({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(title),
        );
      },
    );
  }
}

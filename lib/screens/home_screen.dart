import 'package:flutter/material.dart';
import 'package:new_app/widgets/search_results.dart';
import 'article_category_screen.dart';
import 'package:country/country.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Countries.values.firstWhere((c) => c.alpha2 == 'US');
    _searchController.addListener(() {
      setState(() {
        isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'International News',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        actions: [
          DropdownButton<Country>(
            value: _selectedCountry,
            underline: const SizedBox(),
            icon: Container(),
            items: Countries.values.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.flagEmoji),
                      const SizedBox(width: 1),
                      Text(country.alpha2.toUpperCase()),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (Country? value) {
              if (value == null) return;
              setState(() {
                _selectedCountry = value;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 2.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search articles...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              isSearching
                  ? Expanded(
                      child: SearchResults(searchQuery: _searchController.text),
                    )
                  : Expanded(child: ArticleCategoryScreen()),
            ],
          ),
        ),
      ),
    );
  }
}

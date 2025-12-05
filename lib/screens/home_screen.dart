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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 194, 49, 49),
        elevation: 12,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButton<Country>(
              value: _selectedCountry,
              underline: const SizedBox(),
              items: Countries.values.map((country) {
                return DropdownMenuItem<Country>(
                  value: country,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.flagEmoji),
                      const SizedBox(width: 1),
                      Text(
                        country.alpha2.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 245, 244, 244),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 194, 49, 49),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 2.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.search,
                      color: const Color.fromARGB(
                        255,
                        153,
                        1,
                        1,
                      ).withOpacity(0.64),
                    ),
                    hintText: "Search",
                    hintStyle: TextStyle(
                      color: const Color(0xFF1D1D35).withOpacity(0.64),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0 * 1.5,
                      vertical: 16.0,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
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

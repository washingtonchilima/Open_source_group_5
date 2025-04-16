import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

class SearchAndFilterList extends StatefulWidget {
  const SearchAndFilterList({super.key});

  @override
  State<SearchAndFilterList> createState() => _SearchAndFilterListState();
}

class _SearchAndFilterListState extends State<SearchAndFilterList> {
  late Box<ShoppingItem> _shoppingBox;
  late Box<String> _categoryBox;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _shoppingBox = Hive.box<ShoppingItem>('shopping_items_box');
    _categoryBox = Hive.box<String>('categories_box');

    // Seed default categories if empty
    if (_categoryBox.isEmpty) {
      _categoryBox.addAll(['Groceries', 'Electronics', 'Clothing', 'Other']);
    }

    // Update search query on text change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  List<ShoppingItem> _filterItems(List<ShoppingItem> items) {
    return items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedFilterCategory == 'All' ||
          item.category == _selectedFilterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _shoppingBox.values.toList();
    final filteredItems = _filterItems(items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter & Search Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedFilterCategory,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                    ..._categoryBox.values.map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilterCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: filteredItems.isEmpty
          ? const Center(child: Text('No items match your search/filter.'))
          : ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(
                '${item.category} • Qty: ${item.quantity} • MWK ${item.price.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}

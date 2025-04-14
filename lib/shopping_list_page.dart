import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
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

    if (_categoryBox.isEmpty) {
      _categoryBox.addAll(['Groceries', 'Electronics', 'Clothing', 'Other']);
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    String itemName = '';
    int quantity = 1;
    double price = 0.0;
    String selectedCategory =
    _categoryBox.isNotEmpty ? _categoryBox.getAt(0)! : 'Uncategorized';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  onChanged: (value) => itemName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 1,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: _categoryBox.values
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemName.trim().isNotEmpty) {
                  final item = ShoppingItem(
                    name: itemName,
                    category: selectedCategory,
                    quantity: quantity,
                    price: price,
                  );
                  _shoppingBox.add(item);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(ShoppingItem item) {
    String itemName = item.name;
    int quantity = item.quantity;
    double price = item.price;
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  controller: TextEditingController(text: itemName),
                  onChanged: (value) => itemName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: quantity.toString()),
                  onChanged: (value) => quantity = int.tryParse(value) ?? 1,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: TextEditingController(text: price.toStringAsFixed(2)),
                  onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: _categoryBox.values
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                item.name = itemName;
                item.quantity = quantity;
                item.price = price;
                item.category = selectedCategory;
                item.save();
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _shoppingBox.getAt(index)?.delete();
              Navigator.of(context).pop(); // Close dialog
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  void _toggleItem(int index, bool? value) {
    final item = _shoppingBox.getAt(index);
    if (item != null) {
      item.isChecked = value ?? false;
      item.save();
      setState(() {});
    }
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
  Widget build(BuildContext context) {
    final items = _shoppingBox.values.toList();
    final filteredItems = _filterItems(items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
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
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (value) => _toggleItem(
                  _shoppingBox.values.toList().indexOf(item), value),
            ),
            title: Text(item.name),
            subtitle: Text(
                '${item.category} • Qty: ${item.quantity} • MWK ${item.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditItemDialog(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(
                      _shoppingBox.values.toList().indexOf(item)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

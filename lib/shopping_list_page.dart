import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final List<Map<String, dynamic>> _items = [];
  final List<String> _categories = ['Groceries', 'Electronics', 'Clothing', 'Other'];

  void _showAddItemDialog() {
    String itemName = '';
    int quantity = 1;
    double price = 0.0;
    String selectedCategory = _categories[0];

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
                  items: _categories
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
                  setState(() {
                    _items.add({
                      'name': itemName,
                      'quantity': quantity,
                      'price': price,
                      'category': selectedCategory,
                      'checked': false,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _toggleItem(int index, bool? value) {
    setState(() {
      _items[index]['checked'] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: _items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add one.'))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: Checkbox(
              value: item['checked'],
              onChanged: (value) => _toggleItem(index, value),
            ),
            title: Text(item['name']),
            subtitle: Text(
              '${item['category']} • Qty: ${item['quantity']} • \$${item['price'].toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(index),
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

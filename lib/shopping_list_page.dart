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

  @override
  void initState() {
    super.initState();
    _shoppingBox = Hive.box<ShoppingItem>('shopping_items_box');
    _categoryBox = Hive.box<String>('categories_box');

    // Optional: Ensure defaults exist if categories box is empty
    if (_categoryBox.isEmpty) {
      _categoryBox.addAll(['Groceries', 'Electronics', 'Clothing', 'Other']);
    }
  }

  void _showAddItemDialog() {
    String itemName = '';
    int quantity = 1;
    double price = 0.0;
    String selectedCategory = _categoryBox.isNotEmpty ? _categoryBox.getAt(0)! : 'Uncategorized';

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

  void _deleteItem(int index) {
    _shoppingBox.getAt(index)?.delete();
    setState(() {});
  }

  void _toggleItem(int index, bool? value) {
    final item = _shoppingBox.getAt(index);
    if (item != null) {
      item.isChecked = value ?? false;
      item.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _shoppingBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add one.'))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (value) => _toggleItem(index, value),
            ),
            title: Text(item.name),
            subtitle: Text(
              '${item.category} • Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)}',
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

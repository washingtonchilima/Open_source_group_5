import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import 'package:hive/hive.dart';
import '../provider.dart';
import '../widgets/item_dialogs.dart'; // <-- import this!


class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // ✅ Delay provider mutation until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shoppingBox = Hive.box<ShoppingItem>('shopping_items_box');
      ref.read(shoppingItemsProvider.notifier).loadItems(shoppingBox);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    String itemName = '';
    int quantity = 1;
    double price = 0.0;
    String selectedCategory = 'Groceries';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Item',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                items: ['Groceries', 'Electronics', 'Clothing', 'Other']
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
                ref.read(shoppingItemsProvider.notifier).addItem(item);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Add'),
          ),
        ],
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }


  void _showEditItemDialog(BuildContext context, WidgetRef ref, ShoppingItem item, int index) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.price.toStringAsFixed(2));
    String selectedCategory = item.category;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Item',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                controller: quantityController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: priceController,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Groceries', 'Electronics', 'Clothing', 'Other']
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
              final updatedItem = ShoppingItem(
                name: nameController.text,
                category: selectedCategory,
                quantity: int.tryParse(quantityController.text) ?? 1,
                price: double.tryParse(priceController.text) ?? 0.0,
              );

              ref.read(shoppingItemsProvider.notifier).updateItem(index, updatedItem);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Save'),
          ),
        ],
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

// Replace the _deleteItem method with this
  void _deleteItem(int index) {
    final item = ref.read(shoppingItemsProvider)[index]; // Get the item for confirmation dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(shoppingItemsProvider.notifier).deleteItem(index); // ✅ Pass index
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    final shoppingList = ref.watch(shoppingItemsProvider);
    final filteredItems = _filterItems(shoppingList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        elevation: 4.0,
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 6)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.teal),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedFilterCategory,
                  icon: const Icon(Icons.filter_list, color: Colors.teal),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                    ...['Groceries', 'Electronics', 'Clothing', 'Other']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilterCategory = value;
                      });
                    }
                  },
                  style: const TextStyle(color: Colors.teal),
                  underline: const SizedBox(),
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
          final originalIndex = ref
              .read(shoppingItemsProvider)
              .indexOf(item);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Checkbox(
                value: item.isChecked,
                onChanged: (_) => ref.read(shoppingItemsProvider.notifier).toggleItem(index),
                activeColor: Colors.teal,
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked ? Colors.grey : null,
                ),
              ),
              subtitle: Text(
                '${item.category} • Qty: ${item.quantity} • MWK ${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked ? Colors.grey : null,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showEditItemDialog(context, ref, index, item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showDeleteConfirmationDialog(context, ref,index, item),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddItemDialog(context, ref),
        tooltip: 'Add Item',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
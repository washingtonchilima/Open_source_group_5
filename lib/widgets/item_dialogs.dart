import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../provider.dart';

Future<void> showAddItemDialog(BuildContext context, WidgetRef ref) async {
  String itemName = '';
  int quantity = 1;
  double price = 0.0;
  String selectedCategory = 'Groceries';

  final nameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController(text: '0.00');

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Add Item",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (value) => itemName = value,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) => quantity = int.tryParse(value) ?? 1,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Groceries', 'Electronics', 'Clothing', 'Other']
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
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
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              itemName = nameController.text.trim();
              quantity = int.tryParse(quantityController.text) ?? 1;
              price = double.tryParse(priceController.text) ?? 0.0;

              if (itemName.isNotEmpty) {
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
          ),
        ],
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
  );
}

Future<void> showEditItemDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    ShoppingItem item,
    ) async {
  String itemName = item.name;
  int quantity = item.quantity;
  double price = item.price;
  String selectedCategory = item.category;

  final nameController = TextEditingController(text: itemName);
  final quantityController = TextEditingController(text: quantity.toString());
  final priceController = TextEditingController(text: price.toStringAsFixed(2));

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                controller: nameController,
                onChanged: (value) => itemName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                controller: quantityController,
                onChanged: (value) => quantity = int.tryParse(value) ?? 1,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: priceController,
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
              final updatedItem = ShoppingItem(
                name: itemName,
                quantity: quantity,
                price: price,
                category: selectedCategory,
              );

              ref.read(shoppingItemsProvider.notifier).updateItem(index, updatedItem);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    ShoppingItem item,
    ) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Item',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      content: Text(
        'Are you sure you want to delete "${item.name}" from your list?',
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(shoppingItemsProvider.notifier).deleteItem(index);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
        ),
      ],
    ),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
  );
}

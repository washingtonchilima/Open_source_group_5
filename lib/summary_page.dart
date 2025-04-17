import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late Box<ShoppingItem> _shoppingBox;

  @override
  void initState() {
    super.initState();
    _shoppingBox = Hive.box<ShoppingItem>('shopping_items_box');
  }

  void _clearPurchasedItems() {
    final checkedItems = _shoppingBox.values.where((item) => item.isChecked).toList();
    for (var item in checkedItems) {
      final key = item.key;
      _shoppingBox.put(
        key,
        ShoppingItem(
          name: item.name,
          quantity: item.quantity,
          price: item.price,
          category: item.category,
          isChecked: false, // uncheck instead of delete
        ),
      );
    }
    setState(() {});
  }

  void _selectAllPurchasedItems() {
    final uncheckedItems = _shoppingBox.values.where((item) => !item.isChecked).toList();
    for (var item in uncheckedItems) {
      final key = item.key;
      _shoppingBox.put(
        key,
        ShoppingItem(
          name: item.name,
          quantity: item.quantity,
          price: item.price,
          category: item.category,
          isChecked: true, // check all items
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final checkedItems = _shoppingBox.values.where((item) => item.isChecked).toList();
    final totalCost = checkedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          if (checkedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Summary',
              onPressed: _clearPurchasedItems,
            ),
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'Select All Items',
            onPressed: _selectAllPurchasedItems,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: checkedItems.isEmpty
            ? const Center(child: Text('You haven’t marked any items as purchased yet.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchased Items (${checkedItems.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: checkedItems.length,
                itemBuilder: (context, index) {
                  final item = checkedItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.category} • Qty: ${item.quantity}'),
                    trailing: Text(' MWK ${(item.price * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: MWK ${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

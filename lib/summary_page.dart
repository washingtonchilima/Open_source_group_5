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

  @override
  Widget build(BuildContext context) {
    // Get all checked items
    final checkedItems = _shoppingBox.values.where((item) => item.isChecked).toList();

    // Calculate total cost
    final totalCost = checkedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: checkedItems.isEmpty
            ? const Center(child: Text('No item marked as purchased.'))
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
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

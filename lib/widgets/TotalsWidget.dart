import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_list_provider.dart';

class TotalsWidget extends ConsumerWidget {
  final int listIndex;

  const TotalsWidget({super.key, required this.listIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shoppingListProvider.notifier);
    final overallTotal = notifier.getOverallTotal(listIndex);
    final subtotals = notifier.getCategorySubtotals(listIndex);

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 💰 Overall total
            Text('Overall Total: \$${overallTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.black)),

            const Divider(height: 24),

            // 📊 Subtotals
            const Text('Category Subtotals:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...subtotals.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

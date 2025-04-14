import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/totals_widget.dart';
import '../models/item.dart';

class ShoppingListDetailsScreen extends ConsumerWidget {
  const ShoppingListDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingListProvider);
    final categories = {
      ...items.where((i) => !i.isBought).map((e) => e.category)
    }.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TotalsWidget(), // Shows overall and per-category totals
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryItems = items
                      .where((i) => i.category == category)
                      .toList();

                  return CategorySection(
                    category: category,
                    items: categoryItems,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

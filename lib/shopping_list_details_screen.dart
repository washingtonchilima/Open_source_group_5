import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/totals_widget.dart';
import '../models/item.dart';

class ShoppingListDetailsScreen extends ConsumerWidget {
  const ShoppingListDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListProvider);
    final items = shoppingList.isNotEmpty ? shoppingList.first.items : <Item>[];

    // Group unique categories of unbought items
    final categories = items
        .where((item) => !item.isBought)
        .map((item) => item.category)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TotalsWidget(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryItems = items
                      .where((item) => item.category == category)
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

class CategorySection extends StatelessWidget {
  final String category;
  final List<Item> items;

  const CategorySection({
    Key? key,
    required this.category,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
              );
            },
          ),
        ],
      ),
    );
  }
}

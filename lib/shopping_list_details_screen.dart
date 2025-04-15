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
    // Ensure that items are properly typed as List<Item>
    final items = shoppingList.isNotEmpty ? shoppingList.first.items : <Item>[]; // Empty list of type Item
    final categories = Set<String>.from(
      items.where((i) => !i.isBought).map((e) => e.category),
    ).toList();

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
                  final categoryItems = items.where((i) => i.category == category).toList();

                  // Make sure categoryItems is typed correctly
                  return CategorySection(
                    category: category,
                    items: categoryItems, // Ensure this is a List<Item>
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

// Define CategorySection widget
class CategorySection extends StatelessWidget {
  final String category;
  final List<Item> items; // Explicitly specify the type here

  const CategorySection({
    Key? key,
    required this.category,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: Theme.of(context).textTheme.titleLarge, // Use titleLarge instead of headline6
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
    );
  }
}

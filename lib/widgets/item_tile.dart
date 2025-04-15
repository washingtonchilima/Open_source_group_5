import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/shopping_list_provider.dart';

class ItemTile extends ConsumerWidget {
  final Item item;
  final int listIndex;

  const ItemTile({super.key, required this.item, required this.listIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListProvider)[listIndex];
    final itemIndex = shoppingList.items.indexOf(item);

    return CheckboxListTile(
      title: Text(item.name),
      subtitle: Text(
        '${item.quantity} × \$${item.price.toStringAsFixed(2)} = \$${(item.quantity * item.price).toStringAsFixed(2)}',
      ),
      value: item.isBought,
      onChanged: (_) {
        ref.read(shoppingListProvider.notifier).toggleItemStatus(listIndex, itemIndex);
      },
    );
  }
}

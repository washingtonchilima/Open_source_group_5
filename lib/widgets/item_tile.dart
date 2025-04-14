import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/shopping_list_provider.dart';

class ItemTile extends ConsumerWidget {
  final Item item;

  const ItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref
        .watch(shoppingListProvider)
        .indexWhere((i) => i.name == item.name && i.category == item.category);

    return CheckboxListTile(
      title: Text(item.name),
      subtitle: Text(
          '${item.quantity} × \$${item.price.toStringAsFixed(2)} = \$${item.total.toStringAsFixed(2)}'),
      value: item.isBought,
      onChanged: (_) => ref.read(shoppingListProvider.notifier).toggleBought(index),
    );
  }
}

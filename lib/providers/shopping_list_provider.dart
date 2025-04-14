import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../models/item.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingList>> {
  ShoppingListNotifier() : super([]);

  void addList(ShoppingList list) {
    state = [...state, list];
  }

  void addItem(int listIndex, Item item) {
    final updatedList = [...state];
    updatedList[listIndex].items.add(item);
    state = updatedList;
  }

  void toggleItemStatus(int listIndex, int itemIndex) {
    final updatedList = [...state];
    final item = updatedList[listIndex].items[itemIndex];
    updatedList[listIndex].items[itemIndex] = Item(
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      price: item.price,
      isBought: !item.isBought,
    );
    state = updatedList;
  }

  // 🔢 Get overall total (excluding bought items)
  double getOverallTotal(int listIndex) {
    final items = state[listIndex].items;
    return items.fold(0, (sum, item) =>
    item.isBought ? sum : sum + (item.quantity * item.price));
  }

  // 📊 Get category-wise subtotals (excluding bought items)
  Map<String, double> getCategorySubtotals(int listIndex) {
    final items = state[listIndex].items;
    final result = <String, double>{};

    for (final item in items) {
      if (item.isBought) continue;
      result[item.category] = (result[item.category] ?? 0) + (item.quantity * item.price);
    }

    return result;
  }
}

// 📦 Provider
final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, List<ShoppingList>>(
      (ref) => ShoppingListNotifier(),
);

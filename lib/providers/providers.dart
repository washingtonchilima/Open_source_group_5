import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import 'package:hive/hive.dart';

final shoppingItemsProvider = StateNotifierProvider<ShoppingItemsNotifier, List<ShoppingItem>>(
      (ref) => ShoppingItemsNotifier(),
);

class ShoppingItemsNotifier extends StateNotifier<List<ShoppingItem>> {
  final Box<ShoppingItem> _box = Hive.box<ShoppingItem>('shopping_items_box');

  ShoppingItemsNotifier() : super(Hive.box<ShoppingItem>('shopping_items_box').values.toList());

  // 👇 Add this method
  void loadItems(Box<ShoppingItem> box) {
    state = box.values.toList();
  }

  void addItem(ShoppingItem item) {
    _box.add(item);
    state = _box.values.toList();
  }

  void updateItem(int index, ShoppingItem updatedItem) {
    _box.putAt(index, updatedItem);
    state = _box.values.toList();
  }

  void deleteItem(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  void toggleItem(int index) {
    final item = _box.getAt(index);
    if (item != null) {
      item.isChecked = !item.isChecked;
      item.save();
      state = _box.values.toList();
    }
  }

  double get totalCost => state.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

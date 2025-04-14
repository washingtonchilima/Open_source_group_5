import 'item.dart';

class ShoppingList {
  String title;
  List<Item> items;

  ShoppingList({
    required this.title,
    required this.items,
  });

  double get total =>
      items.where((item) => !item.isBought).fold(0.0, (sum, item) => sum + item.totalPrice);

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (var item in items) {
      if (item.isBought) continue;
      map[item.category] = (map[item.category] ?? 0) + item.totalPrice;
    }
    return map;
  }
}

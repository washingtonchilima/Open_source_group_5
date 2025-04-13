import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String category;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  @HiveField(4)
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.isChecked = false,
  });
}

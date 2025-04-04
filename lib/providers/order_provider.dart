import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class OrderProvider extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _tableOrders = {};

  bool hasOrder(String tableNumber) =>
      _tableOrders.containsKey(tableNumber) &&
      _tableOrders[tableNumber]!['items'].isNotEmpty;

  List<MenuItem> getOrders(String tableNumber) =>
      (_tableOrders[tableNumber]?['items'] as List<MenuItem>?) ?? [];

  String? getNote(String tableNumber) =>
      _tableOrders[tableNumber]?['note'] as String?;

  void updateOrder(
    String tableNumber,
    List<MenuItem> items, {
    String note = '',
  }) {
    if (items.isEmpty) {
      _tableOrders.remove(tableNumber);
    } else {
      _tableOrders[tableNumber] = {'items': items, 'note': note};
    }
    notifyListeners(); // Bu satır önemli!
  }
}

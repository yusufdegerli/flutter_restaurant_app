import 'package:flutter/foundation.dart';
import 'package:sambapos_app_restorant/services/api_service.dart';
import '../models/menu_item.dart';

class OrderProvider with ChangeNotifier {
  Map<String, List<MenuItem>> _orders = {};
  Map<String, DateTime> _orderTimes = {};
  Map<String, String> _orderNotes = {};
  Map<String, String> _orderUserNames = {};
  Map<String, String> _orderUserIds = {};

  void completeOrder(
    String tableNumber,
    List<MenuItem> items, {
    String note = '',
    required String userName,
    required String userId, // String olarak alıyoruz
  }) {
    _orders[tableNumber] = items;
    _orderTimes[tableNumber] = DateTime.now();
    _orderNotes[tableNumber] = note;
    _orderUserNames[tableNumber] = userName;
    _orderUserIds[tableNumber] = userId;
    notifyListeners();
  }

  String? getOrderUserName(String tableNumber) {
    return _orderUserNames[tableNumber];
  }

  String? getOrderUserId(String tableNumber) {
    return _orderUserIds[tableNumber];
  }

  List<MenuItem>? getOrders(String tableNumber) {
    return _orders[tableNumber];
  }

  DateTime? getOrderTime(String tableNumber) {
    return _orderTimes[tableNumber];
  }

  String? getOrderNote(String tableNumber) {
    return _orderNotes[tableNumber];
  }

  bool hasOrder(String tableNumber) {
    return _orders.containsKey(tableNumber) && _orders[tableNumber]!.isNotEmpty;
  }

  void removeOrder(String tableNumber) {
    _orders.remove(tableNumber);
    _orderTimes.remove(tableNumber);
    _orderNotes.remove(tableNumber);
    _orderUserNames.remove(tableNumber);
    _orderUserIds.remove(tableNumber);
    notifyListeners();
  }

  void moveOrder(String sourceTable, String targetTable) {
    if (_orders.containsKey(targetTable) && _orders[targetTable]!.isNotEmpty) {
      throw Exception("Hedef masa (${targetTable}) zaten dolu!");
    }
    _orders[targetTable] = _orders[sourceTable]!;
    _orderTimes[targetTable] = _orderTimes[sourceTable]!;
    _orderNotes[targetTable] = _orderNotes[sourceTable] ?? '';
    _orderUserNames[targetTable] = _orderUserNames[sourceTable] ?? '';
    _orderUserIds[targetTable] = _orderUserIds[sourceTable] ?? '';
    _orders.remove(sourceTable);
    _orderTimes.remove(sourceTable);
    _orderNotes.remove(sourceTable);
    _orderUserNames.remove(sourceTable);
    _orderUserIds.remove(sourceTable);
    notifyListeners();
  }

  //Api'ye post yollama
  Future<void> completeOrderWithApi({
    required String tableNumber,
    required List<MenuItem> items,
    required String note,
    required String userName,
    required String userId,
    required double totalAmount,
  }) async {
    try {
      //Ticket numarası içi garip bir trick
      final ticketNumber = DateTime.now().millisecondsSinceEpoch;

      final orderData = {
        "ticketDto": {
          "Id": 0,
          "Date": DateTime.now().toIso8601String(),
          "LastUpdateTime": DateTime.now().toIso8601String(),
          "TicketNumber": ticketNumber.toString(), // String olarak gönder
          "DepartmentId": 1,
          "LocationName": tableNumber, // Örn: "Masa 5"
          "CustomerId": int.tryParse(userId) ?? 0,
          "CustomerName": userName,
          "Note": note.isNotEmpty ? note : "Not Yok", // Boşsa varsayılan değer
          "IsPaid": false,
          "TotalAmount": totalAmount,
          "RemainingAmount": totalAmount,
          // Yeni eklenen zorunlu alanlar:
          "Tag": "RestaurantOrder", // Backend'in beklediği bir değer olmalı
          "Name": "Sipariş ${ticketNumber.toString()}", // Örn: "Sipariş 123456"
          "CustomersName": userName, // "CustomerName" ile aynı olabilir
        },
      };

      await ApiService.sendOrderToDatabase(orderData);

      //Yerel state'i güncellemek
      completeOrder(
        tableNumber,
        items,
        note: note,
        userName: userName,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Sipariş kaydedilemedi: $e');
    }
  }
}

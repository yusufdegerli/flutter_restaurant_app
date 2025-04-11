import 'package:flutter/foundation.dart';
import 'package:sambapos_app_restorant/services/api_service.dart';
import '../models/menu_item.dart';
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  Map<String, List<MenuItem>> _orders = {};
  Map<String, DateTime> _orderTimes = {};
  Map<String, String> _orderNotes = {};
  Map<String, String> _orderUserNames = {};
  Map<String, String> _orderUserIds = {};
  String? _currentNote;
  String? _currentTableNumber;
  double? _currentTotalAmount;

  void setCurrentOrder({
    String? note,
    String? tableNumber,
    double? totalAmount,
  }) {
    _currentNote = note ?? "Not yok";
    _currentTableNumber = tableNumber ?? "Masa yok";
    _currentTotalAmount = totalAmount ?? 0.0;
    notifyListeners();
  }

  void completeOrder(
    String tableNumber,
    List<MenuItem> items, {
    String note = '',
    required String userName,
    required String userId,
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

  Future<void> completeOrderWithApi({
    required String tableNumber,
    required List<MenuItem> items,
    required String note,
    required String userName,
    required String userId,
    required double totalAmount,
  }) async {
    try {
      final ticketNumber = DateTime.now().millisecondsSinceEpoch;

      final orderData = {
        "ticketDto": {
          "Id": 0,
          "Name": "Sipariş ${ticketNumber.toString()}",
          "DepartmentId": 1,
          "LastUpdateTime": DateTime.now().toIso8601String(),
          "TicketNumber": "TCKT-$ticketNumber",
          "PrintJobData": "2:2#1:1",
          "Date": DateTime.now().toIso8601String(),
          "LastOrderDate": DateTime.now().toIso8601String(),
          "LastPaymentDate": DateTime.now().toIso8601String(),
          "LocationName": tableNumber,
          "CustomerId": int.tryParse(userId) ?? 0,
          "CustomerName": userName,
          "CustomerGroupCode": "misafir",
          "IsPaid": false,
          "RemainingAmount": 23.5,
          "TotalAmount": 123.5,
          "Note": note.isNotEmpty ? note : "Not yok",
          "Locked": false,
          "Tag": "RestaurantOrder",
        },
      };

      print("Gönderilen orderData: ${json.encode(orderData)}");

      await ApiService.sendOrderToDatabase(orderData);

      // Yerel state'i güncelle
      completeOrder(
        tableNumber,
        items,
        note: note,
        userName: userName,
        userId: userId,
      );
    } catch (e) {
      // API'den gelen orijinal hata mesajını loglayalım
      print("API Hata Detayı: $e");
      String errorMessage = 'Sipariş kaydedilemedi: $e';
      if (e.toString().contains('PrintJobData')) {
        errorMessage =
            'Sipariş kaydedilemedi: PrintJobData alanı eksik veya geçersiz. Detay: $e';
      }
      throw Exception(errorMessage);
    }
  }
}

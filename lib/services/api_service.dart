import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sambapos_app_restorant/models/table.dart';
import 'package:sambapos_app_restorant/models/menu_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.35:5235'; // Porta göre güncellendi

  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/Menu'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        throw Exception(
          'Menü öğeleri yüklenemedi. Durum kodu: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('İstek zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Menü öğeleri alınırken hata: $e');
    }
  }

  static Future<Map<String, dynamic>?> validateUser(
    String username,
    String pin,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/User?name=$username'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        final user = users.firstWhere(
          (user) =>
              user['Name'] == username && // API alan adlarına göre güncellendi
              user['PinCode'] == pin &&
              user['UserRole_Id'] != null,
          orElse: () => null,
        );
        if (user != null) {
          return {
            'userId': user['Id'] as int,
            'userRoleId': user['UserRole_Id'] as int,
            'userName': user['Name'] as String,
          };
        }
        return null;
      } else {
        throw Exception(
          'Kullanıcı doğrulanamadı. Durum kodu: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('İstek zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Kullanıcı doğrulanırken hata: $e');
    }
  }

  static Future<List<RestaurantTable>> getTables() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/Table'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => RestaurantTable.fromJson(item)).toList();
      } else {
        throw Exception(
          'Masalar yüklenemedi. Durum kodu: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('İstek zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Masalar alınırken hata: $e');
    }
  }

  //Fiş olarak api'ye yollama
  static Future<void> sendOrderToDatabase(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/Tickets'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(orderData), // ticketDto içeren veri
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw Exception('Sipariş gönderilemedi. Hata: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('İstek zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Sipariş gönderilirken hata: $e');
    }
  }
}

// class OrderProvider with ChangeNotifier {
//   Map<String, List<MenuItem>> _orders = {};
//   Map<String, DateTime> _orderTimes = {};
//   Map<String, String> _orderNotes = {};
//   Map<String, String> _orderUserNames = {};
//   Map<String, String> _orderUserIds = {};
//
//   void completeOrder(
//     String tableNumber,
//     List<MenuItem> items, {
//     String note = '',
//     required String userName,
//     required String userId,
//   }) {
//     _orders[tableNumber] = items;
//     _orderTimes[tableNumber] = DateTime.now();
//     _orderNotes[tableNumber] = note;
//     _orderUserNames[tableNumber] = userName;
//     _orderUserIds[tableNumber] = userId;
//     notifyListeners();
//   }
//
//   String? getOrderUserName(String tableNumber) {
//     return _orderUserNames[tableNumber];
//   }
//
//   String? getOrderUserId(String tableNumber) {
//     return _orderUserIds[tableNumber];
//   }
//
//   List<MenuItem>? getOrders(String tableNumber) {
//     return _orders[tableNumber];
//   }
//
//   DateTime? getOrderTime(String tableNumber) {
//     return _orderTimes[tableNumber];
//   }
//
//   String? getOrderNote(String tableNumber) {
//     return _orderNotes[tableNumber];
//   }
//
//   bool hasOrder(String tableNumber) {
//     return _orders.containsKey(tableNumber) && _orders[tableNumber]!.isNotEmpty;
//   }
//
//   void removeOrder(String tableNumber) {
//     _orders.remove(tableNumber);
//     _orderTimes.remove(tableNumber);
//     _orderNotes.remove(tableNumber);
//     _orderUserNames.remove(tableNumber);
//     _orderUserIds.remove(tableNumber);
//     notifyListeners();
//   }
//
//   void moveOrder(String sourceTable, String targetTable) {
//     if (_orders.containsKey(targetTable) && _orders[targetTable]!.isNotEmpty) {
//       throw Exception("Hedef masa ($targetTable) zaten dolu!");
//     }
//     _orders[targetTable] = _orders[sourceTable]!;
//     _orderTimes[targetTable] = _orderTimes[sourceTable]!;
//     _orderNotes[targetTable] = _orderNotes[sourceTable] ?? '';
//     _orderUserNames[targetTable] = _orderUserNames[sourceTable] ?? '';
//     _orderUserIds[targetTable] = _orderUserIds[sourceTable] ?? '';
//     _orders.remove(sourceTable);
//     _orderTimes.remove(sourceTable);
//     _orderNotes.remove(sourceTable);
//     _orderUserNames.remove(sourceTable);
//     _orderUserIds.remove(sourceTable);
//     notifyListeners();
//   }
// }

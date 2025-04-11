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

  // Tarih formatını ISO 8601'e uygun hale getir
  static String formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return parsedDate.toIso8601String().split('.')[0]; // Milisaniyeleri kaldır
  }

  static Future<void> sendOrderToDatabase(
    Map<String, dynamic> orderData,
  ) async {
    try {
      // Tarih alanlarını formatla
      var ticketDto = orderData['ticketDto'];
      ticketDto['LastUpdateTime'] = formatDateTime(ticketDto['LastUpdateTime']);
      ticketDto['Date'] = formatDateTime(ticketDto['Date']);
      ticketDto['LastOrderDate'] = formatDateTime(ticketDto['LastOrderDate']);
      ticketDto['LastPaymentDate'] = formatDateTime(
        ticketDto['LastPaymentDate'],
      );
      orderData['ticketDto'] = ticketDto;

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/tickets'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(orderData),
          )
          .timeout(const Duration(seconds: 10));

      print("API yanıtı: ${response.statusCode} - ${response.body}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Sipariş gönderilemedi. Hata: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('İstek zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Sipariş gönderilirken hata: $e');
    }
  }
}

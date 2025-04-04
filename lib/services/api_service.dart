import 'package:http/http.dart' as http;
import 'package:sambapos_app_restorant/models/table.dart';
import 'dart:convert';
import 'package:sambapos_app_restorant/models/ticket.dart';
import 'package:sambapos_app_restorant/models/menu_item.dart';

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:5235"; // android emülator localhost adresi. normalde 127.0.0.1

  // Tüm ticket'ları getirme
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Menu'),
      ); // Endpoint
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load menu items. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }

  // ID'ye göre tek ticket getirme
  static Future<Ticket> getTicketById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Tickets/$id'));

      if (response.statusCode == 200) {
        return Ticket.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Ticket not found');
      } else {
        throw Exception(
          'Failed to load ticket. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching ticket: $e');
    }
  }

  //Table'lar için.
  static Future<List<RestaurantTable>> getTables() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Table'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => RestaurantTable.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Tables error: $e');
    }
  }

  // ApiService.dart'a ekleyin
  static Future<bool> validateUser(String username, String pin) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/User?name=$username',
        ), // API endpoint'inize göre düzenleyin
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        // API yapınıza göre veri kontrolü (örnek: userData['pin'] == pin)
        return users.any(
          (user) => user['Name'] == username && user['PinCode'] == pin,
        );
      }
      return false;
    } catch (e) {
      throw Exception('Kullanıcı doğrulanamadı: $e');
    }
  }
}

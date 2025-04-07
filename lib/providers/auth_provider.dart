import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId; // int? olarak tutuyoruz
  int? _userRoleId; // int? olarak tutuyoruz
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId; // Getter düzeltildi
  int? get userRoleId => _userRoleId;
  String? get userName => _userName;

  void login(int userId, int userRoleId, String userName) {
    _isAuthenticated = true;
    _userId = userId; // userId set ediliyor
    _userRoleId = userRoleId;
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _userRoleId = null;
    _userName = null;
    notifyListeners();
  }
}

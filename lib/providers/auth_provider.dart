import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userRoleId;

  bool get isAuthenticated => _isAuthenticated;
  int? get userRoleId => _userRoleId;

  void login(int userRoleId) {
    _isAuthenticated = true;
    _userRoleId = userRoleId;
    notifyListeners(); // Durum değişikliğini bildir
  }

  void logout() {
    _isAuthenticated = false;
    _userRoleId = null;
    notifyListeners();
  }
}

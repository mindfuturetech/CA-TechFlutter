import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  void setAuth({required bool isAuthenticated, User? user}) {
    _isAuthenticated = isAuthenticated;
    _user = user;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
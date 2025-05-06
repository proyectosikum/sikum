import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  bool _loggedIn = false;
  String? _token;

  bool get isLoggedIn => _loggedIn;

  void login(String token) {
    _token = token;
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _loggedIn = false;
    notifyListeners();
  }
}

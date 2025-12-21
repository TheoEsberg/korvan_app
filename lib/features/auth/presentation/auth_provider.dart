import 'package:flutter/foundation.dart';
import '../../../data/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await AuthService.login(username, password);
      if (success) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = "Invalid username or password";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = "Something went wrong. Please try again.";
      if (kDebugMode) {
        print("Login error: $e");
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.clearTokens();
    _status = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}

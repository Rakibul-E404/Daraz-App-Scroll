import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  User?   _user;
  bool    _loading = false;
  String? _error;

  String? get token      => _token;
  User?   get user       => _user;
  bool    get loading    => _loading;
  String? get error      => _error;
  bool    get isLoggedIn => _token != null;

  // ════════════════════════════════════════════════════════════════
  // ✏️  CHANGE THESE TO WHATEVER YOU WANT
  // ════════════════════════════════════════════════════════════════
  static const _myUsername = 'rakibul';
  static const _myPassword = 'rakibul123';
  static const _myName     = 'Rakibul';
  // ════════════════════════════════════════════════════════════════

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    // Reject immediately if credentials don't match
    if (username.trim() != _myUsername || password != _myPassword) {
      _error   = 'Wrong username or password.';
      _loading = false;
      notifyListeners();
      return false;
    }

    // Credentials matched — try real API to get products token
    try {
      // We use johnd credentials only for the API token
      // (fakestoreapi requires their own users for the token endpoint)
      final token = await ApiService.login('johnd', 'm38rmF\$')
          .timeout(const Duration(seconds: 8));
      if (token != null) {
        _token = token;
        _user  = await ApiService.getUser(1);
        // Override the name with your own
        if (_user != null) {
          _user = User(
            id:       _user!.id,
            email:    _user!.email,
            username: _myUsername,
            phone:    _user!.phone,
            name:     UserName(
              firstname: _myName,
              lastname:  _user!.name.lastname,
            ),
            address: _user!.address,
          );
        }
        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Network down — use offline profile
    }

    // Offline fallback — still log in
    _token = 'offline-token';
    _user  = User(
      id:       1,
      email:    'smrakibulalam586@gmail.com',
      username: _myUsername,
      phone:    '+880-1234-567890',
      name:     UserName(firstname: _myName, lastname: ''),
      address:  UserAddress(
        city:    'Dhaka',
        street:  'Mirpur Road',
        number:  1,
        zipcode: '1216',
      ),
    );
    _loading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _token = null;
    _user  = null;
    notifyListeners();
  }
}
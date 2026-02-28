import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final token    = RxnString();
  final user     = Rxn<User>();
  final loading  = false.obs;
  final error    = RxnString();

  bool get isLoggedIn => token.value != null;

  static const _myUsername = 'rakibul';
  static const _myPassword = 'rakibul123';
  static const _myName     = 'Rakibul';
  static const _myEmail    = 'smrakibulalam586@gmail.com';
  static const _myPhone    = '+880-1234-567890';
  static const _myCity     = 'Dhaka';
  static const _myStreet   = 'Mirpur Road';

  User get _myProfile => User(
    id:       1,
    email:    _myEmail,
    username: _myUsername,
    phone:    _myPhone,
    name:     UserName(firstname: _myName, lastname: ''),
    address:  UserAddress(
      city:    _myCity,
      street:  _myStreet,
      number:  1,
      zipcode: '1216',
    ),
  );

  Future<bool> login(String username, String password) async {
    loading.value = true;
    error.value   = null;

    if (username.trim() != _myUsername || password != _myPassword) {
      error.value   = 'Wrong username or password.';
      loading.value = false;
      return false;
    }

    try {
      final tok = await ApiService.login('johnd', 'm38rmF\$')
          .timeout(const Duration(seconds: 8));
      if (tok != null) {
        token.value = tok;
        final apiUser = await ApiService.getUser(1);
        user.value = apiUser != null
            ? User(
          id:       apiUser.id,
          email:    apiUser.email,
          username: _myUsername,
          phone:    apiUser.phone,
          name:     UserName(
            firstname: _myName,
            lastname:  apiUser.name.lastname,
          ),
          address: apiUser.address,
        )
            : _myProfile;
        loading.value = false;
        return true;
      }
    } catch (_) {}

    // Offline fallback
    token.value   = 'offline-token';
    user.value    = _myProfile;
    loading.value = false;
    return true;
  }

  void logout() {
    token.value = null;
    user.value  = null;
  }
}
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the pseudo-session. Deliberately plain shared_preferences, not
/// secure storage: there are no tokens or secrets here, only a display name.
/// A real app would keep auth tokens in flutter_secure_storage / Keychain.
class SessionLocalDatasource {
  SessionLocalDatasource(this._prefs);

  static const _keyUserName = 'session.userName';

  final SharedPreferences _prefs;

  String? readUserName() => _prefs.getString(_keyUserName);

  Future<void> saveUserName(String name) =>
      _prefs.setString(_keyUserName, name);

  Future<void> clear() async {
    await _prefs.remove(_keyUserName);
  }
}

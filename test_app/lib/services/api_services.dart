import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';

class ApiService {

  static const _base = '<ip-addresss>/api';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();


  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/Account/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['token'];
      (await _prefs()).setString('token', token);
      return true;
    }
    return false;
  }

  static Future<bool> signup(
      {required String email,
      required String password,
      required String phone}) async {
    final res = await http.post(
      Uri.parse('$_base/Account/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'password': password, 'phoneNumber': phone}),
    );
    // the API returns 200 on success
    if (res.statusCode == 200) {
      // auto-login after sign-up
      final token = jsonDecode(res.body)['token'];
      (await _prefs()).setString('token', token);
      return true;
    }
    return false;
  }

  static Future<void> logout() async =>
      (await _prefs()).remove('token');

  /* ───────── PROTECTED ───────── */

  static Future<User?> getProfile() async {
    final token = (await _prefs()).getString('token');
    if (token == null) return null;

    // in this API the e-mail lives inside the JWT
    final email = JwtDecoder.decode(token)['email'];

    final res = await http.post(
      Uri.parse('$_base/User/user-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(email),
    );

    return res.statusCode == 200 ? User.fromJson(jsonDecode(res.body)) : null;
  }

  static Future<bool> updateProfile(
      {required String email, required String phone}) async {
    final token = (await _prefs()).getString('token');
    if (token == null) return false;

    final res = await http.put(
      Uri.parse('$_base/User/user-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'email': email, 'phoneNumber': phone}),
    );
    return res.statusCode == 200;
  }
}

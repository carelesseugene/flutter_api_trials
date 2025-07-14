import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../models/project.dart';

class ApiService {

//PROJECT METHODS START
  static Future<List<ProjectSummary>> listProjects() async {
  final res = await _get('projects');          
  if (res.statusCode != 200) throw Exception(res.body);
  return (jsonDecode(res.body) as List)
      .map((e) => ProjectSummary.fromJson(e))
      .toList();
}

static Future<ProjectSummary?> createProject(
    String name, String? description) async {
  final res = await _post('projects', body: {
    'name': name,
    'description': description,
  });
  return res.statusCode == 201
      ? ProjectSummary.fromJson(jsonDecode(res.body))
      : null;
}
static Future<void> deleteProject(String id) async =>
    _delete('projects/$id');

//PROJECT METHODS END
//HELPER METHODS START
 static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
static Future<http.Response> _get(String path) async {
    final token = await _getToken();
    final url = Uri.parse('$_base/$path');
    return http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }
  static Future<http.Response> _post(String path, {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    final url = Uri.parse('$_base/$path');
    return http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body ?? {}));
  }
  static Future<http.Response> _delete(String path) async {
    final token = await _getToken();
    final url = Uri.parse('$_base/$path');
    return http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }
//HELPER METHODS END
  static const _base = 'http://10.0.2.2:5129/api';

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

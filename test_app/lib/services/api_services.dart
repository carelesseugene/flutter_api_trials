import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/hash.dart';

class ApiService {
  static const String baseUrl = 'https://686cd64914219674dcc94e03.mockapi.io/api/testV1/users'; 

  static Future<User?> login(String email, String password) async {
    final hash = hashPassword(password);
    final response = await http.get(Uri.parse('$baseUrl/users?email=$email'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty && data[0]['passwordHash'] == hash) {
        return User.fromJson(data[0]);
      }
    }
    return null;
  }

  static Future<bool> signup(String name, String email, String password) async {
    final hash = hashPassword(password);

    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'passwordHash': hash,
      }),
    );

    return response.statusCode == 201;
  }
}
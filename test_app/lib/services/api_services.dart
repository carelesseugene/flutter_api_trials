import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/board.dart';
import '../models/notification.dart';
import '../models/project.dart';
import '../models/user.dart';

class ApiService {
  static const _host    = 'http://10.0.2.2:5129';
  static const baseUrl  = '$_host/api';

  /* ───────── helpers ───────── */
  static Future<String?> _getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<http.Response> _get(String path) async {
    final token = await _getToken();
    return http.get(Uri.parse('$baseUrl/$path'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  static Future<http.Response> _post(String path,
      {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    return http.post(Uri.parse('$baseUrl/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body ?? {}));
  }

  static Future<http.Response> _delete(String path) async {
    final token = await _getToken();
    return http.delete(Uri.parse('$baseUrl/$path'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  static Future<http.Response> _patch(String path,
      {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    return http.patch(Uri.parse('$baseUrl/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body ?? {}));
  }

  /* ==============================================================
     AUTH
     ============================================================== */
  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Account/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
    return false;
  }

  static Future<bool> signup({
    required String email,
    required String password,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Account/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'phoneNumber': phone,
      }),
    );

    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
    return false;
  }

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove('token');

  static Future<User?> getProfile() async {
    final token = await _getToken();
    if (token == null) return null;

    final email = JwtDecoder.decode(token)['email'];
    

    final res = await http.post(
      Uri.parse('$baseUrl/User/user-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(email),
    );

    return res.statusCode == 200 ? User.fromJson(jsonDecode(res.body)) : null;
  }

  static Future<bool> updateProfile({
    required String email,
    required String phone,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final res = await http.put(
      Uri.parse('$baseUrl/User/user-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email, 'phoneNumber': phone}),
    );
    return res.statusCode == 200;
  }

  /* ==============================================================
     PROJECTS
     ============================================================== */
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

  static Future<ProjectDetails?> getProjectDetails(String projectId) async {
    final res = await _get('projects/$projectId');
    if (res.statusCode != 200) return null;
    return ProjectDetails.fromJson(jsonDecode(res.body));
  }

  /* ==============================================================
     INVITATIONS & NOTIFICATIONS
     ============================================================== */
  static Future<void> inviteUser(String projectId, String email) async {
    final res = await _post('projects/$projectId/invite',
        body: {'email': email.trim()});
    if (res.statusCode != 200) throw Exception(res.body);
  }

  static Future<List<NotificationDto>> getNotifications() async {
    final res = await _get('notifications');
    if (res.statusCode != 200) throw Exception(res.body);

    final list = jsonDecode(res.body) as List;
    return list.map((e) => NotificationDto.fromJson(e)).toList();
  }

  static Future<void> respondInvite(String projectId, bool accept) async {
    final res = await _post(
        'notifications/$projectId/invites/${accept ? 'accept' : 'reject'}');
    if (res.statusCode != 204) throw Exception(res.body);
  }

  /* ==============================================================
     BOARD
     ============================================================== */
  static Future<List<BoardColumn>> getBoard(String projectId) async {
    final res = await _get('projects/$projectId/board');
    if (res.statusCode != 200) throw Exception(res.body);

    return (jsonDecode(res.body) as List)
        .map((e) => BoardColumn.fromJson(e))
        .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
  }

  static Future<BoardColumn> addColumn(String projectId, String title) async {
    final res =
        await _post('projects/$projectId/columns', body: {'title': title});
    if (res.statusCode != 201) throw Exception(res.body);
    return BoardColumn.fromJson(jsonDecode(res.body));
  }

  static Future<TaskCard> addCard(
      String projectId, String columnId, String title) async {
    final res = await _post('projects/$projectId/columns/$columnId/cards',
        body: {'title': title});
    if (res.statusCode != 201) throw Exception(res.body);
    return TaskCard.fromJson(jsonDecode(res.body));
  }

  static Future<void> deleteColumn(String projectId, String colId) async {
    final res = await _delete('projects/$projectId/columns/$colId');
    if (res.statusCode != 204) throw Exception(res.body);
  }

  static Future<void> deleteCard(String projectId, String cardId) async {
    final res = await _delete('projects/$projectId/cards/$cardId');
    if (res.statusCode != 204) throw Exception(res.body);
  }

  static Future<void> moveCard({
    required String projectId,
    required String cardId,
    required String targetColumnId,
    required int newPosition,
  }) async {
    final res = await _patch('projects/$projectId/cards/$cardId/move', body: {
      'targetColumnId': targetColumnId,
      'newPosition': newPosition,
    });
    if (res.statusCode != 204) throw Exception(res.body);
  }
  static Future<void> leaveProject(String projectId) async {
  await _delete('projects/$projectId/leave');
}

static Future<void> removeMember(String projectId, String userId) async {
  await _delete('projects/$projectId/members/$userId');
}

}

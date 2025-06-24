import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/diary.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['access_token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['access_token']);
      prefs.setString('user', json.encode(data['user']));
      return {
        'success': true,
        'message': data['message'] ?? 'Registrasi berhasil',
      };
    }

    return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
  }

  static Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'login': login, 'password': password},
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['access_token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['access_token']);
      prefs.setString('user', json.encode(data['user']));
      return {'success': true, 'message': data['message'] ?? 'Login berhasil'};
    }

    return {'success': false, 'message': data['message'] ?? 'Login gagal'};
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    prefs.clear();
  }

  static Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<List<Diary>> getDiaries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/diaries'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['data'];
      return list.map((e) => Diary.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data diary');
    }
  }

  static Future<Diary> getDiaryById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Diary.fromJson(data['data']);
    } else {
      throw Exception('Gagal memuat data diary dengan ID $id');
    }
  }

  static Future<bool> createDiary({
    required String date,
    required String title,
    required String content,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/diaries'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'date': date, 'title': title, 'content': content},
    );

    return response.statusCode == 201;
  }

  static Future<bool> updateDiary({
    required int id,
    required String date,
    required String title,
    required String content,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'date': date, 'title': title, 'content': content},
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> deleteDiary(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final body = json.decode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Terjadi kesalahan saat menghapus diary.',
      };
    }
  }
}

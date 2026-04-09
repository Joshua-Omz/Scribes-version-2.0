import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiClient {
  final String baseUrl;
  String? _token;

  ApiClient({this.baseUrl = 'http://localhost:8080/api'});

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<List<Post>> getFeed() async {
    final response =
        await http.get(Uri.parse('$baseUrl/posts'), headers: _headers);
    if (response.statusCode == 200) {
      final List data =
          jsonDecode(response.body)['posts'] ?? jsonDecode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Failed to load feed');
  }

  Future<List<Note>> getNotes() async {
    final response =
        await http.get(Uri.parse('$baseUrl/notes'), headers: _headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Note.fromJson(e)).toList();
    }
    throw Exception('Failed to load notes');
  }
}

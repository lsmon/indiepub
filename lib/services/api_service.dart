import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indiepub/models/user.dart';
import 'package:indiepub/models/event.dart';
import 'package:indiepub/models/post.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.0.16:8008'; // Replace with your API

  ApiService();

  
  Future<AppUser?> login(String email, String password) async {
    final payload = {'email': email, 'password': password};
    final payloadJson = jsonEncode(payload);
    
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: payloadJson,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return AppUser.fromJson(jsonDecode(responseData['data']));
    }
    return null;
  }

  Future<AppUser?> signup(String email, String password, String role) async {
    final payload = {'email': email, 'password': password, 'role': role};
    final payloadJson = jsonEncode(payload);

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: payloadJson,
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return AppUser.fromJson(jsonDecode(responseData['data']));
    }
    return null;
  }

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch events');
  }

  Future<void> createEvent(Event event) async {
    final payloadJson = jsonEncode(event.toMap());

    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: payloadJson,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create event');
    }
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch posts');
  }

  Future<void> createPost(Post post) async {
    final payloadJson = jsonEncode(post.toMap());
    
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'encrypted_data': payloadJson}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final String baseUrl = Config.backendUrl;

  Future<List<dynamic>> fetchMatches() async {
    final uri = Uri.parse('$baseUrl/pets/matches');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load matches: ${res.statusCode}');
    }
  }
}

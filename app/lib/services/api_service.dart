import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fact_check_result.dart';

class ApiService {
  // Replace with your deployed backend URL or use 10.0.2.2 for Android emulator localhost
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<FactCheckResult> quickCheck(String claim) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'claim': claim}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return FactCheckResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to check claim: ${response.statusCode}');
  }

  Future<FactCheckResult> deepCheck(String claim) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/deep-check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'claim': claim}),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return FactCheckResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
        deep: true,
      );
    }
    throw Exception('Failed to deep-check claim: ${response.statusCode}');
  }
}

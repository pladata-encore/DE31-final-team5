import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NutritionRepository {
  final String apiUrl =
      dotenv.env['HOME_SCREEN_API_URL'] ?? ''; // Home 화면 API URL

  // 토큰을 SharedPreferences에서 가져와 사용하는 메서드
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // 저장된 토큰을 가져옴
  }

  Future<Map<String, dynamic>> fetchNutritionData() async {
    try {
      final token = await _getToken(); // 저장된 토큰을 가져옴
      if (token == null) {
        throw Exception('No token found'); // 토큰이 없는 경우 예외 처리
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // 저장된 토큰을 헤더에 추가
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load nutrition data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}

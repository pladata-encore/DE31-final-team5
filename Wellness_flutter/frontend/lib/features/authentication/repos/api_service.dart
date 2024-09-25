import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Logger _logger = Logger();

  // 새로운 토큰을 받아서 저장하는 메서드
  Future<void> _updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_token', newToken);
    _logger.i('Token updated successfully: $newToken');
  }

  // API 호출 시 토큰 만료를 확인하고 재발행된 토큰을 저장하는 로직
  Future<void> callApiWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('custom_token');

    try {
      final response = await http.get(
        Uri.parse('http://example.com/api/resource'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        // 토큰이 만료된 경우
        _logger.w('Token expired, requesting a new token...');

        // 새로운 토큰을 발급받음 (예시로 refreshToken 사용)
        final newToken = await _refreshToken();

        // 새로운 토큰을 SharedPreferences에 저장
        await _updateToken(newToken);

        // 다시 API 호출 (재발행된 토큰으로)
        await callApiWithToken();
      } else {
        // API 호출 성공 처리
        _logger.i('API call successful with token: $token');
      }
    } catch (e) {
      _logger.e('Error during API call: $e');
    }
  }

  // 토큰 재발행 함수 (refreshToken을 사용한 예시)
  Future<String> _refreshToken() async {
    final response = await http.post(
      Uri.parse('http://example.com/api/token/refresh'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': 'your-refresh-token',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['newToken'];
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}

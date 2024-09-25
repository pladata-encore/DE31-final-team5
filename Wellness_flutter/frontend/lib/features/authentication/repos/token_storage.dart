import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class TokenStorage {
  static final Logger _logger = Logger(); // Logger 인스턴스 생성

  // 토큰을 SharedPreferences에 저장 (access_token과 refresh_token 함께 저장)
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken); // access_token 저장
    await prefs.setString('refresh_token', refreshToken); // refresh_token 저장

    _logger.i(
        "Tokens saved: access_token=$accessToken, refresh_token=$refreshToken");
  }

  // SharedPreferences에서 access_token과 refresh_token을 가져옴
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && refreshToken != null) {
      _logger.i(
          "Tokens found: access_token=$accessToken, refresh_token=$refreshToken");
    } else {
      _logger.w("No tokens found");
    }

    // 두 토큰을 Map으로 반환
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  // SharedPreferences에서 access_token과 refresh_token을 삭제
  static Future<void> removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _logger.i("Tokens removed");
  }

  // 기존 access_token과 refresh_token을 비교하여 업데이트
  static Future<void> updateTokensIfNeeded(
      String newAccessToken, String newRefreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    final String? currentAccessToken = prefs.getString('access_token');
    final String? currentRefreshToken = prefs.getString('refresh_token');

    // Access token이 다르면 업데이트
    if (currentAccessToken != newAccessToken) {
      await prefs.setString('access_token', newAccessToken);
      _logger.i(
          "Access token updated from $currentAccessToken to $newAccessToken");
    } else {
      _logger.i("Access token is the same, no update needed.");
    }

    // Refresh token이 다르면 업데이트
    if (currentRefreshToken != newRefreshToken) {
      await prefs.setString('refresh_token', newRefreshToken);
      _logger.i(
          "Refresh token updated from $currentRefreshToken to $newRefreshToken");
    } else {
      _logger.i("Refresh token is the same, no update needed.");
    }
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/authentication/repos/token_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoLoginService {
  final Logger _logger = Logger();

  // 카카오 로그인
  Future<Map<String, String?>> signInWithKakao() async {
    _logger.d("카카오 로그인 시도");

    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
        _logger.i('카카오톡으로 로그인 성공, kakao_token: ${token.accessToken}');
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
        _logger.i('카카오계정으로 로그인 성공, kakao_token: ${token.accessToken}');
      }

      // 사용자 정보 가져오기
      User? user = await UserApi.instance.me();
      String? nickname = user.kakaoAccount?.profile?.nickname;
      String? email = user.kakaoAccount?.email;

      if (nickname == null || email == null) {
        _logger.e('Failed to fetch user info from Kakao.');
        return {'nickname': null, 'email': null};
      }

      _logger.i('Kakao login successful, nickname: $nickname, email: $email');
      return {'nickname': nickname, 'email': email};
    } catch (error) {
      _logger.e('카카오 로그인 실패: $error');
      return {'nickname': null, 'email': null};
    }
  }

  // 로그인 API 호출 (신규/기존 유저 확인)
  Future<bool> loginToBackend(String nickname, String email) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['LOGIN_API_URL'] ?? ''),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nickname': nickname,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final accessToken = data['detail']['wellness_info']['access_token'];
        final refreshToken = data['detail']['wellness_info']['refresh_token'];

        // 토큰 저장
        await TokenStorage.updateTokensIfNeeded(accessToken, refreshToken);

        _logger.i(
            'Tokens are saved successfully: Access: $accessToken / Refresh: $refreshToken');
        _logger.i(response.body);

        return true; // 로그인 성공
      } else if (jsonDecode(response.body)['detail'] == "User not found") {
        _logger.i('User not found. This is a new user.');
        return false; // 신규 유저
      } else {
        _logger.e('Failed to login: ${response.body}');
        return false;
      }
    } catch (error) {
      _logger.e('Error logging in: $error');
      return false;
    }
  }

  // 로그아웃 로직 (토큰은 삭제하지 않음)
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout(); // 카카오 로그아웃 호출
      _logger.i('카카오 로그아웃 성공');
      _logger.i('Token remains in local storage');
    } catch (e) {
      _logger.e('카카오 로그아웃 실패: $e');
      throw Exception('로그아웃 실패');
    }
  }
}

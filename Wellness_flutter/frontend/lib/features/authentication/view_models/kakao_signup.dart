import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK import
import 'dart:async'; // TimeoutException 사용을 위해 추가
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoSignupService {
  final Logger _logger = Logger();

  // 카카오 로그인 로직 추가
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

  // 회원가입 API 호출
  Future<bool> signupWithAdditionalInfo(String nickname, String email,
      String birthday, String gender, String height, String weight) async {
    try {
      // Body에 들어갈 데이터를 미리 생성하고 로그로 출력
      final bodyData = jsonEncode({
        'nickname': nickname,
        'email': email,
        'birthday': birthday,
        'gender': gender,
        'height': height,
        'weight': weight,
      });

      _logger.d('회원가입 요청 Body: $bodyData'); // 요청 Body를 로그로 출력

      final response = await http
          .post(
            Uri.parse(dotenv.env['SIGNUP_API_URL'] ?? ''),
            headers: {
              'Content-Type': 'application/json',
            },
            body: bodyData,
          )
          .timeout(const Duration(seconds: 10)); // 타임아웃 설정

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _logger.i('회원가입 성공: ${response.body}');

        // 응답에 wellness_info 필드가 있는지 확인하고 access_token과 refresh_token 추출
        if (data.containsKey('detail') &&
            data['detail'].containsKey('wellness_info')) {
          final accessToken = data['detail']['wellness_info']['access_token'];
          final refreshToken = data['detail']['wellness_info']['refresh_token'];

          // 엑세스 토큰과 리프레시 토큰 저장 (비교하지 않고 바로 저장)
          await _saveTokensToLocal(accessToken, refreshToken);
          _logger.i('Access token saved successfully: $accessToken');
          _logger.i('Refresh token saved successfully: $refreshToken');
          return true;
        } else {
          _logger.e('Response does not contain access_token: ${response.body}');
          return false;
        }
      } else {
        // 상태 코드와 응답 본문을 로그로 기록
        _logger
            .e('Failed to sign up: ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException {
      _logger.e('Request timed out during sign-up');
      return false;
    } catch (error) {
      _logger.e('Error signing up: $error');
      return false;
    }
  }

  // access_token과 refresh_token을 로컬 저장소에 저장
  Future<void> _saveTokensToLocal(
      String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken); // access_token 저장
      await prefs.setString('refresh_token', refreshToken); // refresh_token 저장
      await prefs.setBool('signUp', true);

      _logger.i(
          'Tokens saved locally: access_token=$accessToken, refresh_token=$refreshToken, signUp= true');
    } catch (e) {
      _logger.e('Failed to save tokens: $e');
      throw Exception('토큰 저장 실패');
    }
  }
}

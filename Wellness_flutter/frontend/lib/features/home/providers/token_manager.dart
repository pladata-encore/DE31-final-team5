import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/features/authentication/repos/token_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenManager {
  final BuildContext context;

  final Logger logger = Logger();

  TokenManager({required this.context});

  Future<void> refreshToken() async {
    try {
      // SharedPreferences에서 현재 access token과 refresh token을 불러옴
      Map<String, String?> tokens = await TokenStorage.getTokens();
      String? accessToken = tokens['access_token'];
      String? refreshToken = tokens['refresh_token'];

      // accessToken이나 refreshToken이 없다면 에러 처리
      if (accessToken == null || refreshToken == null) {
        throw Exception('No tokens found');
      }

      // API 요청 전송
      final response = await http.post(
        Uri.parse(dotenv.env['TOKEN_VALIDATION_URL'] ?? ''), //토큰 재발급 api
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // 헤더에 현재 access token 포함
        },
        body: jsonEncode({
          'refresh_token': refreshToken, // 바디에 refresh token 포함
        }),
      );

      // 공통된 응답 처리 로직
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('응답이 200 또는 201임');
        await handleTokenResponse(responseBody);
      } else if (response.statusCode == 401) {
        logger.w('401 Unauthorized: refresh 토큰이 유효하지 않습니다.');
        await handleExpiredRefreshToken(responseBody);
      } else {
        logger.e('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error refreshing token: $e');
    }
  }

  // 리프레시 토큰 만료 이외의 경우 처리
  Future<void> handleTokenResponse(Map<String, dynamic> response) async {
    final status = response['status'];

    if (status == 'VALID_ACCESS_TOKEN') {
      // Access token이 유효한 경우
      logger.i('Access token is still valid.');
    } else if (status == 'VALID_REFRESH_TOKEN') {
      // Access token 만료, refresh token 유효 - 새로 받은 access token 저장
      logger.w('Access 토큰이 만료되었습니다.');
      final newAccessToken = response['access_token'];
      final newRefreshToken = response['refresh_token'];
      // token_storage.dart 파일의 메서드를 사용해 새로 받은 토큰 업데이트
      await TokenStorage.updateTokensIfNeeded(newAccessToken, newRefreshToken);
      logger.i('Tokens have been renewed and updated.');
    }
  }

  // 리프레시 토큰 만료 처리
  Future<void> handleExpiredRefreshToken(Map<String, dynamic> response) async {
    final status = response['status'];

    if (status == 'EXPIRED_REFRESH_TOKEN') {
      logger.w('Refresh token이 만료되어 로그인 페이지로 이동합니다.');

      // 리프레시 토큰 만료 - 팝업 띄운 후 로그인 화면으로 이동
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그인 필요'),
            content: const Text('다시 로그인 해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                  context.go('/login'); // 로그인 화면으로 이동
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}

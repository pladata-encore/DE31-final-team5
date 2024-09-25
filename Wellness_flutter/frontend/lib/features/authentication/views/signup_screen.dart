import 'package:flutter/material.dart';
import 'package:frontend/constants/sizes.dart';
import 'package:frontend/constants/gaps.dart';
import 'package:frontend/features/authentication/view_models/kakao_login.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger();

class SignupScreen extends StatefulWidget {
  static String routeName = "signup";
  static String routeURL = "/signup";

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();

  // 카카오 로그인 로직 호출 및 화면 이동
  void _onKakaoLoginTap(BuildContext context) async {
    _logger.i('Kakao signup button tapped');
    _logger.i('signup is false, proceeding with Kakao login');

    // 카카오 로그인 진행 후 유저 정보 확인
    final userInfo = await _kakaoLoginService.signInWithKakao();
    _logger.i('Kakao login response: $userInfo');

    if (userInfo['nickname'] != null && userInfo['email'] != null) {
      // 로그인 API 호출하여 신규/기존 유저 판별
      final loginSuccess = await _kakaoLoginService.loginToBackend(
          userInfo['nickname']!, userInfo['email']!);

      if (loginSuccess) {
        // 기존 유저일 경우 홈 화면으로 이동
        _logger.i('Existing user, navigating to HomeScreen');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('sign_up', true); // sign_up = true 저장
        context.go('/home/home'); // 홈 화면으로 이동
      } else {
        // 신규 유저일 경우 생년월일 입력 화면으로 이동
        _logger.i('Navigating to BirthdayScreen after Kakao login');
        context.go('/birthday', extra: {
          'nickname': userInfo['nickname'],
          'email': userInfo['email'],
        });
      }
    } else {
      _logger.w('Kakao login failed or returned incomplete info');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('SignupScreen build started');
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/new_rabbit.png',
                  height: 200,
                ),
                Gaps.v20,
                const Text(
                  "WELLNESS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "appname",
                    fontSize: Sizes.size32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v20,
                const Opacity(
                  opacity: 0.7,
                  child: Text(
                    "사진 업로드 한 번으로 끝내는",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "pretendard-regular",
                      fontSize: Sizes.size16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Gaps.v10,
                const Opacity(
                  opacity: 0.7,
                  child: Text(
                    "'빠르고 간편한' 식단 관리 앱",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "pretendard-regular",
                      fontSize: Sizes.size16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Gaps.v40,
                _KakaoLoginButton(onTap: _onKakaoLoginTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KakaoLoginButton extends StatefulWidget {
  final void Function(BuildContext) onTap;

  const _KakaoLoginButton({required this.onTap});

  @override
  _KakaoLoginButtonState createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<_KakaoLoginButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(Sizes.size12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Image.asset(
          'assets/images/kakao_signup.png',
          //fit: BoxFit.contain,
        ),
      ),
    );
  }
}

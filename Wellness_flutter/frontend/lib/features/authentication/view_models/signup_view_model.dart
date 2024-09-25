import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/authentication/repos/authentication_repo.dart';
import 'package:frontend/features/users/view_models/user_profile_model.dart';
import 'package:frontend/features/users/view_models/users_view_model.dart';

class SignupViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepoitory _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<void> signUp(BuildContext context) async {
    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);
    final users = ref.read(usersProvider.notifier);

    try {
      // 회원가입을 위해 이메일과 비밀번호 사용
      await _authRepo.emailSignUp(
        form["email"]!,
        form["password"]!,
      );

      // 사용자 프로필 생성
      final profile = UserProfileModel(
        // bio: form["bio"] ?? '',
        // link: form["link"] ?? '',
        email: form["email"]!,
        uid: "dummy-uid", // 실제 서버나 인증 시스템을 사용할 경우, 여기에 UID를 할당
        nickname: form["nickname"] ?? '',
        age: int.tryParse(form["age"]?.toString() ?? '0') ?? 0,
        gender: form["gender"] ?? '',
        height: double.tryParse(form["height"] ?? '0') ?? 0.0,
        weight: double.tryParse(form["weight"] ?? '0') ?? 0.0,
      );

      await users.createProfile(profile);

      // 성공 시 상태를 업데이트하고 로그인 화면으로 이동
      if (context.mounted) {
        // context.mounted로 위젯이 여전히 활성 상태인지 확인
        state = const AsyncValue.data(null);
        context.goNamed('login'); // 로그인 화면으로 이동
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // 오류 발생 시 스낵바로 사용자에게 알림
      if (context.mounted) {
        // context.mounted로 위젯이 여전히 활성 상태인지 확인
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $e')),
        );
      }
    }
  }
}

final signUpForm = StateProvider<Map<String, dynamic>>((ref) => {});

final signUpProvider = AsyncNotifierProvider<SignupViewModel, void>(
  () => SignupViewModel(),
);

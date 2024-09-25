import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/users/view_models/user_profile_model.dart';
import 'package:frontend/features/users/repos/user_repo.dart';

class UsersViewModel extends AsyncNotifier<UserProfileModel> {
  late final DummyUserRepository _usersRepository;

  @override
  FutureOr<UserProfileModel> build() async {
    _usersRepository = ref.read(userRepo);

    // 예제에서는 'user-id'를 고정된 값으로 사용, 실제로는 인증된 사용자의 UID를 사용해야 합니다.
    final profile = await _usersRepository.findProfile('user-id');
    if (profile != null) {
      return UserProfileModel.fromJson(profile);
    }

    // 사용자 프로필이 없는 경우 빈 프로필 반환
    return UserProfileModel.empty();
  }

  // 새로운 사용자 프로필을 생성하는 메서드
  Future<void> createProfile(UserProfileModel profile) async {
    state = const AsyncValue.loading();
    try {
      await _usersRepository.createProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 사용자의 프로필을 업데이트하는 메서드
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (state.value == null) return;

    // 상태를 업데이트한 후 더미 리포지토리에 반영
    state = AsyncValue.data(state.value!.copyWith(
      // bio: updates['bio'] ?? state.value!.bio,
      // link: updates['link'] ?? state.value!.link,
      gender: updates['gender'] ?? state.value!.gender,
      height: updates['height']?.toDouble() ?? state.value!.height,
      weight: updates['weight']?.toDouble() ?? state.value!.weight,
    ));
    await _usersRepository.updateUser(state.value!.uid, updates);
  }
}

final usersProvider = AsyncNotifierProvider<UsersViewModel, UserProfileModel>(
  () => UsersViewModel(),
);

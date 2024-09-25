import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/users/view_models/user_profile_model.dart';

class DummyUserRepository {
  // 메모리에 사용자 데이터를 저장하는 맵
  final Map<String, UserProfileModel> _users = {};

  // UID를 기준으로 사용자 프로필을 찾는 메서드
  Future<Map<String, dynamic>?> findProfile(String uid) async {
    // 서버가 있다고 가정하고 약간의 딜레이를 줍니다.
    await Future.delayed(const Duration(seconds: 1));

    // 사용자가 있으면 데이터를 반환하고, 없으면 null 반환
    if (_users.containsKey(uid)) {
      return _users[uid]!.toJson();
    } else {
      return null;
    }
  }

  // 새로운 사용자 프로필을 생성하는 메서드
  Future<void> createProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(seconds: 1));
    _users[profile.uid] = profile; // 사용자 프로필 저장
  }

  // 사용자의 프로필을 업데이트하는 메서드
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      _users[uid] = user.copyWith(
        // bio: updates['bio'] ?? user.bio,
        // link: updates['link'] ?? user.link,
        gender: updates['sex'] ?? user.gender,
        age: updates['age'] ?? user.age,
        height: updates['height']?.toDouble() ?? user.height,
        weight: updates['weight']?.toDouble() ?? user.weight,
      );
    }
  }
}

final userRepo = Provider((ref) => DummyUserRepository());

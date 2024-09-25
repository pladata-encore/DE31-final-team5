class UserProfileModel {
  // final String bio; // 간단한 자기 소개
  // final String link; // 사용자가 추가할 웹사이트 링크
  final String email; // 사용자의 이메일
  final String uid; // 사용자의 고유 식별자
  final String nickname; // 사용자의 이름
  final int age; //사용자의 나이
  final String gender; // 사용자의 성별
  final double height; // 사용자의 키
  final double weight; // 사용자의 몸무게

  UserProfileModel({
    // required this.bio,
    // required this.link,
    required this.email,
    required this.uid,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      // bio: json['bio'] ?? '',
      // link: json['link'] ?? '',
      email: json['email'] ?? '',
      uid: json['uid'] ?? '',
      nickname: json['nickname'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'bio': bio,
      // 'link': link,
      'email': email,
      'uid': uid,
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }

  UserProfileModel copyWith({
    // String? bio,
    // String? link,
    String? email,
    String? uid,
    String? nickname,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) {
    return UserProfileModel(
      // bio: bio ?? this.bio,
      // link: link ?? this.link,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  static UserProfileModel empty() {
    return UserProfileModel(
      // bio: '',
      // link: '',
      email: '',
      uid: '',
      nickname: '',
      age: 0,
      gender: '',
      height: 0.0,
      weight: 0.0,
    );
  }
}

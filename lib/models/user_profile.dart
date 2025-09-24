class UserProfile {
  final String? id;
  final String userId;
  final String? selfIntroduction;
  final String? mbit;
  final String? idealType;
  final String? profileImagePath;

  const UserProfile({
    this.id,
    required this.userId,
    this.selfIntroduction,
    this.mbit,
    this.idealType,
    this.profileImagePath,
  });

  UserProfile copyWith({
    String? selfIntroduction,
    String? mbit,
    String? idealType,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      selfIntroduction: selfIntroduction ?? this.selfIntroduction,
      mbit: mbit ?? this.mbit,
      idealType: idealType ?? this.idealType,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      selfIntroduction: json['selfIntroduction'] as String?,
      mbit: json['mbit'] as String?,
      idealType: json['idealType'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (selfIntroduction != null) 'selfIntroduction': selfIntroduction,
      if (mbit != null) 'mbit': mbit,
      if (idealType != null) 'idealType': idealType,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
    };
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String? gender;
  final String kakaoId;
  final String? birthDate;
  final String? phoneNumber;
  final String accountStatus;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    this.gender,
    required this.kakaoId,
    this.birthDate,
    this.phoneNumber,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

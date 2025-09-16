// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  gender: json['gender'] as String?,
  kakaoId: json['kakaoId'] as String,
  birthDate: json['birthDate'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  accountStatus: json['accountStatus'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'gender': instance.gender,
  'kakaoId': instance.kakaoId,
  'birthDate': instance.birthDate,
  'phoneNumber': instance.phoneNumber,
  'accountStatus': instance.accountStatus,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      isNewUser: json['isNewUser'] as bool,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'isNewUser': instance.isNewUser,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) => AuthModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'tokenType': instance.tokenType,
    };

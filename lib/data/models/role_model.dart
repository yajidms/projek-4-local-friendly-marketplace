import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';

part 'role_model.g.dart';

@JsonSerializable()
class RoleModel {
  final String value;

  RoleModel({required this.value});

  /// Convert model to domain entity
  Role toEntity() => RoleExtension.fromString(value);

  /// Create model from domain entity
  factory RoleModel.fromEntity(Role role) {
    return RoleModel(value: role.value);
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);

  /// Create model from JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

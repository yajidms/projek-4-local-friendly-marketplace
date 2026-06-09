import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';
import 'user_local_datasource.dart';

class HiveUserLocalDataSource implements UserLocalDataSource {
  static const _boxName = 'users';
  static const _currentUserIdKey = 'current_user_id';

  Future<Box<String>> get _box => Hive.openBox<String>(_boxName);

  @override
  Future<UserModel?> getUserById(String id) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final box = await _box;
    return box.values
        .map((json) => UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final box = await _box;
    await box.put(user.id, jsonEncode(user.toJson()));
  }

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    final box = await _box;
    for (final user in users) {
      await box.put(user.id, jsonEncode(user.toJson()));
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final box = await _box;
    await box.put(user.id, jsonEncode(user.toJson()));
  }

  @override
  Future<void> deleteUser(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final box = await _box;
    final currentId = box.get(_currentUserIdKey);
    if (currentId == null) return null;
    final json = box.get(currentId);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    final box = await _box;
    await box.put(user.id, jsonEncode(user.toJson()));
    await box.put(_currentUserIdKey, user.id);
  }
}

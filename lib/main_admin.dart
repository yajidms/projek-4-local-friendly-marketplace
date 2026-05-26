import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/env.dart';
import 'admin/admin_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox('products');
  await Hive.openBox('reviews');
  // Admin might not need to seed data directly, but we open boxes if needed.

  runApp(const AdminApp());
}

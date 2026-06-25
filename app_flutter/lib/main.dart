import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local SQLite database before running the app
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint("Failed to initialize SQLite database: $e");
  }

  runApp(const ClientRadarApp());
}

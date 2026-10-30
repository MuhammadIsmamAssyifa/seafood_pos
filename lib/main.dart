import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app/app.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent storage
  await GetStorage.init();

  // Initialize environment (development by default)
  EnvConfig.init(environment: AppEnvironment.production);

  runApp(const App());
}

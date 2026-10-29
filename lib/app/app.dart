import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.fade,
    );
  }
}


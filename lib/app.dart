import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';

/// Root widget. `ProviderScope` is installed in `main.dart`.
class ForYouApp extends StatelessWidget {
  const ForYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '702FORU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        // Clamp text scaling so large accessibility settings cannot break
        // layouts, while still respecting the user's preference.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

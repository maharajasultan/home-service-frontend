import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/config/api_config.dart';
import 'package:reaple_app/core/responsive/app_scroll_behavior.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/theme/app_theme.dart';

class ReapleApp extends ConsumerWidget {
  const ReapleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: ApiConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: ref.watch(routerProvider),
      // Batasi pembesaran font sistem agar layout tidak pecah (tetap ramah aksesibilitas).
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
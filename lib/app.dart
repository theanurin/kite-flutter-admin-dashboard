import 'dart:ui' show Brightness;

import 'package:flutter/material.dart' show BuildContext, Widget;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:kite_ui/shadcn.dart' show ShadApp;

import './core/l10n/locale_controller.dart' show localeProvider;
import './core/router/app_router.dart' show routerProvider;
import './core/theme/app_theme.dart' show themeProvider;
import './l10n/app_localizations.dart' show L;

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return ShadApp.router(
      title: 'Kite',
      themeMode: theme.mode,
      theme: theme.data(Brightness.light),
      darkTheme: theme.data(Brightness.dark),
      locale: locale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: L.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

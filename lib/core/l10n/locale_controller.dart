import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart' show L;

const sortedLandCodes = ['en', 'ja', 'ar', 'es', 'fr'];

class LocaleController extends Notifier<Locale> {
  static List<Locale>? _sortedLocales = null;
  static List<Locale> get sortedLocales {
    if (_sortedLocales != null) {
      return _sortedLocales!;
    }

    final sourceLocales = L.supportedLocales.toList();

    final List<Locale> targetLocales = List.empty(growable: true);

    for (final landCode in sortedLandCodes) {
      final index = sourceLocales.indexWhere((l) => l.languageCode == landCode);
      if (index == -1) {
        throw StateError(
          'Project does not have localization for lang: "$landCode"',
        );
      }
      targetLocales.add(sourceLocales.removeAt(index));
    }

    if (sourceLocales.isNotEmpty) {
      throw StateError(
        'Const sortedLandCodes does not have localization for langs: "${sourceLocales.join(', ')}"',
      );
    }

    return _sortedLocales = targetLocales;
  }

  @override
  Locale build() {
    return sortedLocales.first;
  }

  void set(Locale value) => state = value;
}

final localeProvider = NotifierProvider<LocaleController, KiteLocale>(
  LocaleController.new,
);

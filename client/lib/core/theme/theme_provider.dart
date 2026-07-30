import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'scribes_colors.dart';
import '../../main.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier with WidgetsBindingObserver {
  static const _themeKey = 'scribes_selected_theme';

  @override
  ScribesColors build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    return _getTheme();
  }

  ScribesColors _getTheme() {
    final themeString = sharedPrefs.getString(_themeKey);
    if (themeString == 'parchment') return ScribesColors.parchment;
    if (themeString == 'silver') return ScribesColors.silver;
    if (themeString == 'night') return ScribesColors.night;
    
    // Default to system theme if not explicitly set
    final brightness = PlatformDispatcher.instance.platformBrightness;
    return brightness == Brightness.dark ? ScribesColors.night : ScribesColors.silver;
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Only auto-update if the user hasn't explicitly set a theme
    if (sharedPrefs.getString(_themeKey) == null) {
      state = _getTheme();
    }
  }

  void setTheme(ScribesColors? theme) {
    if (theme == null) {
      // Clear preference to revert to system theme
      sharedPrefs.remove(_themeKey);
      state = _getTheme();
      return;
    }

    state = theme;
    
    String themeString = 'night';
    if (theme == ScribesColors.parchment) themeString = 'parchment';
    if (theme == ScribesColors.silver) themeString = 'silver';
    
    sharedPrefs.setString(_themeKey, themeString);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'scribes_colors.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ScribesColors build() {
    return ScribesColors.night;
  }

  void setTheme(ScribesColors theme) {
    state = theme;
  }
}

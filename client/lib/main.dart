import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(
      child: ScribesApp(),
    ),
  );
}

class ScribesApp extends ConsumerWidget {
  const ScribesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeColors = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Scribes',
      theme: ThemeData(
        scaffoldBackgroundColor: themeColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColors.gold,
          brightness: themeColors.background.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
        ),
        extensions: [themeColors],
      ),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
    );
  }
}

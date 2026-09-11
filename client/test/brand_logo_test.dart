import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scribes/core/widgets/scribes_brand_logo.dart';
import 'package:scribes/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  testWidgets('ScribesBrandLogo renders all variants without error', (tester) async {
    for (final variant in BrandLogoVariant.values) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScribesBrandLogo(variant: variant),
            ),
          ),
        ),
      );
      expect(find.byType(ScribesBrandLogo), findsOneWidget);
    }
  });
}

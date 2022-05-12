import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/ui/aboutscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockPlatformWrapper extends Mock implements PlatformWrapper {}

void main() {
  group('Test about screen layout', () {
    String _version = "1.0";
    String _build = "2";
    late MockPlatformWrapper platformWrapper;

    setUp(
      () {
        platformWrapper = MockPlatformWrapper();
        when(() => platformWrapper.openUrl(any(),
            external: any(named: 'external'))).thenAnswer((_) async => true);

        PackageInfo.setMockInitialValues(
          appName: "abc",
          packageName: "com.getwedge.wedge",
          version: _version,
          buildNumber: _build,
          buildSignature: "buildSignature",
        );
      },
    );

    testWidgets(
        'After startup, there should be a title called CarbPro text, about_carbpro as title '
        'and an image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("CarbPro"), findsOneWidget);
      expect(find.text(S.current.about), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

  });
}

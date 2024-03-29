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

    testWidgets('The about screen should display the version and build number',
        (WidgetTester tester) async {
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

      expect(find.text('${S.current.version}: $_version'), findsOneWidget);
      expect(find.text('${S.current.build}: $_build'), findsOneWidget);
    });

    testWidgets('All the content should be in a single scroll view',
        (WidgetTester tester) async {
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

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
        'About screen should display the app_description and the developer_info',
        (WidgetTester tester) async {
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

      expect(find.text(S.current.app_description), findsOneWidget);
      expect(find.text(S.current.app_developer_info), findsOneWidget);
    });

    testWidgets(
        'The about screen should contain a website button, '
        ' after a click, StorageHandler should be called',
        (WidgetTester tester) async {
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

      final AboutScreenState myWidgetState =
          tester.state(find.byType(AboutScreen));
      myWidgetState.platformWrapper = platformWrapper;

      expect(find.text(S.current.website), findsOneWidget);
      await tester.ensureVisible(find.text(S.current.website));
      await tester.tap(find.text(S.current.website));
      verify(() => platformWrapper.openUrl(
          any(that: equals('https://carbpro.neofix.ch')),
          external: any(named: 'external', that: isTrue))).called(1);
    });

    testWidgets(
        'The about screen should contain a github button, '
        ' after a click, StorageHandler should be called',
        (WidgetTester tester) async {
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

      final AboutScreenState myWidgetState =
          tester.state(find.byType(AboutScreen));
      myWidgetState.platformWrapper = platformWrapper;

      expect(find.text(S.current.github), findsOneWidget);
      await tester.ensureVisible(find.text(S.current.github));
      await tester.tap(find.text(S.current.github));
      verify(() => platformWrapper.openUrl(
          any(that: equals('https://github.com/maheini/CarbPro')),
          external: any(named: 'external', that: isTrue))).called(1);
    });
  });
}

import 'dart:io';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/ui/widgets/image_getter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(CameraDevice.front);
  });

  group(
    'Test Layout',
    () {
      testWidgets(
        'Check if selection pops up',
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
                home: Builder(
                  builder: (context) {
                    return Scaffold(
                      body: ElevatedButton(
                        onPressed: () => ImageGetter().getImage(context),
                        child: const Text('button'),
                      ),
                    );
                  },
                )),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('button'));
          await tester.pump();

          expect(find.text(S.current.camera), findsOneWidget);
          expect(find.byIcon(Icons.camera), findsOneWidget);
          expect(find.text(S.current.gallery), findsOneWidget);
          expect(find.byIcon(Icons.image), findsOneWidget);
        },
      );

      testWidgets(
        'Test if popup is dismissible',
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
                home: Builder(
                  builder: (context) {
                    return Scaffold(
                      body: ElevatedButton(
                        onPressed: () => ImageGetter().getImage(context),
                        child: const Text('button'),
                      ),
                    );
                  },
                )),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('button'));
          await tester.pump();
          expect(find.text(S.current.camera), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pump();

          expect(find.text(S.current.camera), findsNothing);
        },
      );
    },
  );

  group('test functionality of the widget', () {
    // TODO check if camera is called with the right settings
    // TODO check if gallery is called with the right settings

    // TODO check if camera returns null, the return is also null
    // TODO check if gallery returns null, the return is also null
  });
}

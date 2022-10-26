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
        'Test if popup is dismissible and image file is null',
        (WidgetTester tester) async {
          File? imageFile;

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
                        onPressed: () async {
                          imageFile = await ImageGetter().getImage(context);
                        },
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
          expect(imageFile, isNull);
        },
      );
    },
  );

  group('test functionality of the widget', () {
    late ImagePicker imagePicker;

    setUp(() {
      imagePicker = MockImagePicker();
      when(() => imagePicker.pickImage(
                source: any(named: "source"),
                maxWidth: any(named: "maxWidth"),
                maxHeight: any(named: "maxHeight"),
                imageQuality: any(named: "imageQuality"),
                preferredCameraDevice: any(named: "preferredCameraDevice"),
              ))
          .thenAnswer((realInvocation) =>
              Future.value(XFile('assets/storagehandler_test_image.jpg')));
    });

    testWidgets(
        'Test if tap on camera button is opening Image picker '
        'and correct image is returned', (WidgetTester tester) async {
      ImageGetter imageGetter = ImageGetter();
      imageGetter.imagePicker = imagePicker;
      File? imageFile;

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
                    onPressed: () async {
                      imageFile = await imageGetter.getImage(context);
                    },
                    child: const Text('button'),
                  ),
                );
              },
            )),
      );
      await tester.pump();

      await tester.tap(find.text('button'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.camera));
      await tester.pumpAndSettle();

      expect(imageFile?.path, 'assets/storagehandler_test_image.jpg');
      expect(find.text(S.current.camera), findsNothing);
    });

    testWidgets(
        'Test if tap on gallery button is opening Image picker '
        'and correct image is returned', (WidgetTester tester) async {
      ImageGetter imageGetter = ImageGetter();
      imageGetter.imagePicker = imagePicker;
      File? imageFile;

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
                    onPressed: () async {
                      imageFile = await imageGetter.getImage(context);
                    },
                    child: const Text('button'),
                  ),
                );
              },
            )),
      );
      await tester.pump();

      await tester.tap(find.text('button'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.gallery));
      await tester.pumpAndSettle();

      expect(imageFile?.path, 'assets/storagehandler_test_image.jpg');
      expect(find.text(S.current.gallery), findsNothing);
    });
  });
}

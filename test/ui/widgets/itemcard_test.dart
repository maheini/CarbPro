import 'dart:io';
import 'dart:typed_data';
import 'package:carbpro/ui/widgets/itemcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {}

void main() {
  group(
    'Test itemcard display behaviour',
    () {
      testWidgets(
        'Check if all values are visible',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300,
                  child: ItemCard(
                    title: 'title',
                    value: 11.2,
                    image: null,
                  ),
                ),
              ),
            ),
          );

          expect(find.text('title'), findsOneWidget);
          expect(find.text('11.2 g KH'), findsOneWidget);
          expect(find.byIcon(Icons.wallpaper), findsOneWidget);
        },
      );

      testWidgets(
        'Check if Image gets loaded if there is one and replacement icon isn"t visible',
        (WidgetTester tester) async {
          File mockFile = MockFile();
          Uint8List fileContent =
              (await rootBundle.load('assets/default_icon.png'))
                  .buffer
                  .asUint8List();
          when(() => mockFile.readAsBytes())
              .thenAnswer((invocation) async => fileContent);
          when(() => mockFile.path).thenReturn('path');

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300,
                  child: ItemCard(
                    title: 'title',
                    value: 11.2,
                    image: mockFile,
                  ),
                ),
              ),
            ),
          );

          verify(() => mockFile.readAsBytes()).called(1);
          expect(find.byIcon(Icons.wallpaper), findsNothing);
        },
      );

      testWidgets(
        'Check if tap is called if the card is tapped',
        (WidgetTester tester) async {
          bool check = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300,
                  child: ItemCard(
                    title: 'title',
                    value: 11.2,
                    image: File(''),
                    onTap: () => check = true,
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.byType(ItemCard));

          expect(check, true);
        },
      );

      testWidgets(
        'Check if longPress is called if the card is pressed long',
        (WidgetTester tester) async {
          bool check = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300,
                  child: ItemCard(
                    title: 'title',
                    value: 11.2,
                    image: File(''),
                    onLongPress: () => check = true,
                  ),
                ),
              ),
            ),
          );

          await tester.longPress(find.byType(ItemCard));

          expect(check, true);
        },
      );
    },
  );
}

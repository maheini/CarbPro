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

    },
  );
}

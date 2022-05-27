import 'package:carbpro/ui/widgets/emtylistplaceholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI of emptylistplaceholder', () {
    testWidgets('should display a message and an image',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: const EmptyListPlaceholder(
            text: 'message',
          ),
        ),
      );

      expect(find.text('message'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

  });
}

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

    testWidgets('If theme is dark, arrow_white.png should be displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const EmptyListPlaceholder(
            text: 'message',
          ),
        ),
      );

      final Image image = find.byType(Image).evaluate().single.widget as Image;

      String source = '';
      if (image.image is AssetImage) {
        source = (image.image as AssetImage).assetName;
      }
      expect(source, 'assets/arrow_white.png');
    });

  });
}

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
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('message'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('If title is set, it should be displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: const EmptyListPlaceholder(
            text: 'message',
            title: 'title',
          ),
        ),
      );

      expect(find.byType(Text), findsNWidgets(2));
      expect(find.text('message'), findsOneWidget);
      expect(find.text('title'), findsOneWidget);
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

    testWidgets('If theme is light, arrow_black.png should be displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
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
      expect(source, 'assets/arrow_black.png');
    });
  });
}

import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/detailscreen.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';

import 'detailscreen_test.mocks.dart';


@GenerateMocks([DatabaseHandler, StorageHandler])
void main() {
  group('Test Detailscreen AppBar', () {
    MockDatabaseHandler databaseHandler = MockDatabaseHandler();
    setUp(() {
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
    });

    testWidgets('After Item got loaded, Appbar should display the Item name and a edit Icon', (WidgetTester tester) async {
      when(databaseHandler.getItem(1)).thenAnswer((_) async => Future.value(Item(1, 'ItemName')));
      when(databaseHandler.getChildren(1)).thenAnswer((_) async => Future.value([]));

      // start app
      await tester.pumpWidget(const MaterialApp(home: DetailScreen(id: 1)));
      await tester.pump();

      expect(find.text('ItemName'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('After pressing the edit Icon, a popup should appear. With this popup, '
        'the name of the item should be changeable', (WidgetTester tester) async {
      when(databaseHandler.getItem(1)).thenAnswer((_) async => Future.value(Item(1, 'ItemName')));
      when(databaseHandler.getChildren(1)).thenAnswer((_) async => Future.value([]));

      // start app
      await tester.pumpWidget(const MaterialApp(home: DetailScreen(id: 1)));
      await tester.pump();

      // press edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Check if Popup is visible
      expect(find.text('ItemName'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('ABBRECHEN'), findsOneWidget);
      expect(find.text('SPEICHERN'), findsOneWidget);

      // press cancel and check if popup disappears
      await tester.tap(find.text('ABBRECHEN'));
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
      expect(find.text('ItemName'), findsOneWidget);

      //press edit button again
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // clear text and try to save (should not save)
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('SPEICHERN'));
      verifyNever(databaseHandler.changeItemName(any, any));

      // change name
      await tester.enterText(find.byType(TextField), 'NewItemName');
      when(databaseHandler.changeItemName(1, 'NewItemName'))
          .thenAnswer((realInvocation) => Future.value(1));
      verify(databaseHandler.changeItemName(1, 'NewItemName'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('NewItemName'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    tearDown(() {
      // reset locator
      locator.resetScope(dispose: true);
    });
  });
}
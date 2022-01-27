import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'homescreen_test.mocks.dart';
import 'package:carbpro/locator/locator.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@GenerateMocks([DatabaseHandler, StorageHandler])
void main(){
  group('App startup', () {
    testWidgets('Open App and check if Circular Progress is visisible while opening the database', (WidgetTester tester) async{
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([Item(1,'Item1')]));

      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingletonAsync<DatabaseHandler>(() async {
        await Future.delayed(const Duration(milliseconds: 3));
        return databaseHandler;
      });

      await tester.pumpWidget(const CarbPro());

      expect(find.byType (AlertDialog), findsNothing);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.pump(const Duration(seconds: 5));
      locator.resetScope(dispose: true);
    });

    testWidgets('Return one fake Item from the Database -> Home should list this '
        'and show add+search button without warning and progress indicator', (WidgetTester tester) async {
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([Item(1, 'Item1')]));

      await tester.pumpWidget(const CarbPro());
      await tester.pump();

      expect(find.byType (AlertDialog), findsNothing);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      locator.resetScope(dispose: true);
    });
  });

  group('Test search method', () {
    testWidgets('After tapping search button, the title should be replaced by a Textfield', (WidgetTester tester) async {
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([]));

      await tester.pumpWidget(const CarbPro());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType (AlertDialog), findsNothing);
      expect(find.text('CarbPro'), findsNothing);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.text('Item2'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      locator.resetScope(dispose: true);
    });
  });
}
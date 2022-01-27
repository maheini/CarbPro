import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:carbpro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'homescreen_test.mocks.dart';

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

  group('Test search functionality', () {

    testWidgets(''
        'Test if Search bar appear, and filtering List items. '
        'Also test if Search bar disappear after clear icon got pressed',
            (WidgetTester tester) async {
      // Setup all dependencies
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([
        Item(1, 'Item1'),
        Item(2, 'Item2'),
      ]));

      // start Widget
      await tester.pumpWidget(const CarbPro());
      await tester.pump();

      // Check if AppBar contains Search bar Icon and title and List is unfiltered
      expect(find.byType (AlertDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.text('Item2'), findsOneWidget);

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // ensure AppBar doesn't contain Title and Search Icon
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.text('CarbPro'), findsNothing);

      // filter all Items containing '2'
      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();

      // Check if search bar is filtering out 'Item1'
      expect(find.text('Item1'), findsNothing);
      expect(find.text('Item2'), findsOneWidget);

      // Close Search bar by tapping onto the clear icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Check if Search bar has disappeared and Items are unfiltered
      expect(find.byType (AlertDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.text('Item2'), findsOneWidget);

      locator.resetScope(dispose: true);
    });


    testWidgets(''
        'Test if Search bar appear, and filtering List items. '
        'Also test if Search bar disappear after back button got pressed',
            (WidgetTester tester) async {
      // Setup all dependencies
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([
        Item(1, 'Item1'),
        Item(2, 'Item2'),
      ]));

      // start Widget
      await tester.pumpWidget(const CarbPro());
      await tester.pump();

      // Check if AppBar contains Search bar Icon and title and List is unfiltered
      expect(find.byType (AlertDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.text('Item2'), findsOneWidget);

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // ensure AppBar doesn't contain Title and Search Icon
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.text('CarbPro'), findsNothing);

      // filter all Items containing '2'
      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();

      // Check if search bar is filtering out 'Item1'
      expect(find.text('Item1'), findsNothing);
      expect(find.text('Item2'), findsOneWidget);

      // ensure AppBar doesn't contain Title and Search Icon
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.text('CarbPro'), findsNothing);

      // Close Search bar by simulating a back button pressed
      final ByteData message = const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
      await ServicesBinding.instance!.defaultBinaryMessenger
          .handlePlatformMessage('flutter/navigation', message, (_) { });
      await tester.pump();

      // Check if Search bar has disappeared and Items are unfiltered
      expect(find.byType (AlertDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Item1'), findsOneWidget);
      expect(find.text('Item2'), findsOneWidget);

      locator.resetScope(dispose: true);
    });

  });
}
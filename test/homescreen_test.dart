import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/homescreen.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:carbpro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

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

  group('Test Item List', () {
    testWidgets('DetailScreen should be loaded after a click onto a Item', (WidgetTester tester) async{
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([Item(1, 'Item1')]));
      RouteSettings? routeSettings;

      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: (settings) {
          routeSettings = settings;
          if(settings.name == '/' || settings.name == '/details'){
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          }
          return null;
        }
      ));
      await tester.pump();

      // tap item1
      await tester.tap(find.text('Item1'));
      await tester.pump();

      //check if route '/details' was called with argument int = 1
      expect(routeSettings, isNotNull);
      expect(routeSettings!.arguments as int, 1);
      locator.resetScope(dispose: true);
    });

    testWidgets('A Popup should appear after lonPressing on an Item'
        '-After tapping the cancel button, everything should be canceled'
        '-After pressing confirm, the item should disappear', (WidgetTester tester) async {
      // prepare dependencies
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      MockStorageHandler storageHandler = MockStorageHandler();
      locator.registerSingleton<StorageHandler>(storageHandler);
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([Item(1, 'Item1')]));

      // load widget
      await tester.pumpWidget(const CarbPro());
      await tester.pump();

      // longPress item1
      await tester.longPress(find.text('Item1'));
      await tester.pump();

      // expect a Alertdialog containing a text with a 'ABBRECHEN' or 'ENTFERNEN' option
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('ENTFERNEN'), findsOneWidget);
      expect(find.text('ABBRECHEN'), findsOneWidget);

      // press 'ABBRECHEN'
      await tester.tap(find.text('ABBRECHEN'));
      await tester.pump();

      // Expect the initial list, containing all items as before and no alert dialog
      expect(find.text('Item1'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Prepare mocks for removing the Item
      when(databaseHandler.getChildren(1))
          .thenAnswer((realInvocation) => Future.value([ItemChild(11,1,'', 'path')]));
      when(databaseHandler.getItems())
          .thenAnswer((realInvocation) => Future.value([]));
      when(storageHandler.getPermission(Permission.storage, any))
          .thenAnswer((realInvocation) => Future.value(true));
      when(storageHandler.deleteFile('path'))
          .thenAnswer((realInvocation) => Future.value());

      // longPress item1 again to remove it this time
      await tester.longPress(find.text('Item1'));
      await tester.pump();

      // press 'ENTFERNEN'
      await tester.tap(find.text('ENTFERNEN'));

      // check if every necessary function get called
      verify(storageHandler.getPermission(Permission.storage, any)).called(1);
      verify(databaseHandler.getChildren(1)).called(1);
      verify(storageHandler.deleteFile('path')).called(1);

      // load to check if item isn't visible anymore
      await tester.pump();

      // expect no longer any Item1 inside the list and no alertdialog
      expect(find.text('Item1'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);

      // reset locator
      locator.resetScope(dispose: true);
    });

  });
}
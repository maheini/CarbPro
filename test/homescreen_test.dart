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
    // testWidgets('Open App and check if Circular Progress is visisible while opening the database', (WidgetTester tester) async{
    //   locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
    //   locator.registerSingletonAsync<DatabaseHandler>(() async {
    //     return MockDatabaseHandler();
    //   }, signalsReady: true);
    //   setupLocator();
    //
    //   await tester.pumpWidget(const CarbPro());
    //
    //   expect(find.byType (AlertDialog), findsNothing);
    //   expect(find.text('CarbPro'), findsOneWidget);
    //   expect(find.byIcon(Icons.add), findsNothing);
    //   expect(find.byIcon(Icons.search), findsNothing);
    //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // });

    testWidgets('Return one fake Item from the Database -> Home should list this '
        'and show add+search button without warning and progress indicator', (WidgetTester tester) async {
      MockDatabaseHandler databaseHandler = MockDatabaseHandler();
      locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      Item item = Item(1, 'Test-Item');
      when(databaseHandler.getItems()).thenAnswer((_) async => Future.value([item]));

      await tester.pumpWidget(const CarbPro());
      await tester.pump();

      expect(find.byType (AlertDialog), findsNothing);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.text('Test-Item'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
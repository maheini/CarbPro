import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/detailscreen.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:image_picker/image_picker.dart';

import 'detailscreen_test.mocks.dart';


@GenerateMocks([DatabaseHandler, StorageHandler, ImagePicker])
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

  group('Test add Button behaviour', () {
    MockDatabaseHandler databaseHandler = MockDatabaseHandler();
    MockStorageHandler storageHandler = MockStorageHandler();
    setUp(() {
      locator.registerSingleton<DatabaseHandler>(databaseHandler);
      locator.registerSingleton<StorageHandler>(storageHandler);
    });

    testWidgets('Check if Addbutton is aviable -> after clicking on it, '
        'a popup should appear with with a field of name and image', (WidgetTester tester) async {
      when(databaseHandler.getItem(1)).thenAnswer((_) async => Future.value(Item(1, 'ItemName')));
      when(databaseHandler.getChildren(1)).thenAnswer((_) async => Future.value([]));
      
      await tester.pumpWidget(const MaterialApp(home: DetailScreen(id: 1)));
      await tester.pump();
      
      // tap add-item button
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pump();
      
      // expect a popup with textfield and add-image icon
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.wallpaper), findsOneWidget);
      expect(find.text('SPEICHERN'), findsOneWidget);
      expect(find.text('ABBRECHEN'), findsOneWidget);
      
      // try pressing save -> the popup should be closed, nothing should happen
      verifyNever(databaseHandler.addItemChild(any));
      await tester.tap(find.text('SPEICHERN'));
      await tester.pump();

      // expect home screen
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.wallpaper), findsNothing);
      expect(find.text('SPEICHERN'), findsNothing);
      expect(find.text('ABBRECHEN'), findsNothing);
      
      // again add item, press ´ABBRECHEN´ this time
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pump();
      verifyNever(databaseHandler.addItemChild(any));
      await tester.tap(find.text('ABBRECHEN'));
      await tester.pump();
    });

    testWidgets('click addbutton and afterwards try to add an image & text & store them', 
            (WidgetTester tester) async {
      MockImagePicker imagePicker = MockImagePicker();
      when(imagePicker.pickImage(source: ImageSource.camera))
          .thenAnswer((realInvocation) => Future.value(null));  // todo: pass fake image
      when(databaseHandler.getItem(1)).thenAnswer((_) async => Future.value(Item(1, 'ItemName')));
      when(databaseHandler.getChildren(1)).thenAnswer((_) async => Future.value([]));

      await tester.pumpWidget(const MaterialApp(home: DetailScreen(id: 1)));
      await tester.pump();

      // tap add-item button
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pump();
      
      // Pick image and enter name
      locator.registerLazySingleton<ImagePicker>(() => imagePicker);
      await tester.tap(find.byIcon(Icons.wallpaper));
      await tester.enterText(find.byType(TextField), 'ItemChild');
      await tester.pump();

      // save everything
      when(databaseHandler.addItemChild(any))
          .thenAnswer((realInvocation) => Future.value(2));
      when(storageHandler.copyFile(any, any))
          .thenAnswer((_) => Future.value()); // todo: pass fake file
      verify(databaseHandler.addItem(any)).called(1);
      verify(storageHandler.copyFile(any, any)).called(1);
      await tester.tap(find.text('SPEICHERN'));
      await tester.pumpAndSettle();

      // expect home with one widget to show up
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.wallpaper), findsNothing);
      expect(find.text('SPEICHERN'), findsNothing);
      expect(find.text('ABBRECHEN'), findsNothing);
      expect(find.text('ItemChild'), findsOneWidget);
    });


    tearDown(() {
      // reset locator
      locator.resetScope(dispose: true);
    });
  });

}
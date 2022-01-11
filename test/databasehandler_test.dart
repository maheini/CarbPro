import 'package:carbpro/databasehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'databasehandler_test.mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';


@GenerateMocks([Database])
void main(){
  group('Testing all Item methods', () {
    //Testing getItems method
    test('DatabaseHandler method getItems should return 2 valid Items', () async{
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([{'id': 1, 'name': 'name'},{'id': 2, 'name': 'name2'}]);
      when(database.rawQuery('SELECT * FROM items'))
          .thenAnswer((_) async => future);

      // Act
      List<Item> actual = await databaseHandler.getItems();

      // Assert
      expect(actual.length, 2);
    });
    test('This time, getItems should return 1 item inside the List, '
        'because the Database is returning a invalid item in the first row data', () async{
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([{'id': 1}, {'id': 2, 'name': 'hi'}]);
      when(database.rawQuery('SELECT * FROM items'))
          .thenAnswer((_) async => future);

      // Act
      List<Item> actual = await databaseHandler.getItems();

      // Assert
      expect(actual.length, 1);
    });

    // testing addItem method
    test('addItem should return a value of 1 row affected', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawInsert('INSERT INTO items (name) VALUES (?)', ['TestName'])).thenAnswer((_) => Future.value(1));

      // Act
      final rowsAffected = await databaseHandler.addItem('TestName');

      // Assert
      expect(rowsAffected, 1);
    });
    test('addItem should return a value of 0 row affected (fake return from DB)', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawInsert('INSERT INTO items (name) VALUES (?)', ['TestName'])).thenAnswer((_) => Future.value(0));

      // Act
      final rowsAffected = await databaseHandler.addItem('TestName');

      // Assert
      expect(rowsAffected, 0);
    });

    // testing deleteItem method
    test('deleteItem should return 1 row affected', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawDelete('DELETE FROM items WHERE id = ?', [1])).thenAnswer((_) => Future.value(1));

      // Act
      final rowsAffected = await databaseHandler.deleteItem(1);

      // Assert
      expect(rowsAffected, 1);
    });
    test('deleteItem should return 0 row affected because there id no id = 0', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawDelete('DELETE FROM items WHERE id = ?', [0])).thenAnswer((_) => Future.value(0));

      // Act
      final rowsAffected = await databaseHandler.deleteItem(0);

      // Assert
      expect(rowsAffected, 0);
    });
    
    // test deleteAllChildren
    test('This test should return 3 affected rows', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawDelete('DELETE FROM content WHERE parent = ?', [1])).thenAnswer((_) => Future.value(3));

      // Act
      final int rowsAffected = await databaseHandler.deleteAllChildren(1);
      
      // Assert
      expect(rowsAffected, 3);
    });
    test('This test should return 0 affected rows (faked DB return)', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawDelete('DELETE FROM content WHERE parent = ?', [2])).thenAnswer((_) => Future.value(0));

      // Act
      final int rowsAffected = await databaseHandler.deleteAllChildren(2);

      // Assert
      expect(rowsAffected, 0);
    });

    //test changeItemName
    test('This test should run a query to change the item name and return all affected rows (1)', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawUpdate('UPDATE items SET name = ? WHERE id = ?', ['TestName', 1])).thenAnswer((_) => Future.value(1));

      // Act
      final int rowsAffected = await databaseHandler.changeItemName(1, 'TestName');

      // Assert
      expect(rowsAffected, 1);
    });
    test('This test should run a query to change the item name and return all affected rows (0, because there is no id 0)', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(mockDatabase.rawUpdate('UPDATE items SET name = ? WHERE id = ?', ['TestName', 0])).thenAnswer((_) => Future.value(0));

      // Act
      final int rowsAffected = await databaseHandler.changeItemName(0, 'TestName');

      // Assert
      expect(rowsAffected, 0);
    });

  }); // End of Item Tests in DatabaseHandler

  group('Testing all the Children Methods in DatabaseHandler', () {

    test('Should return 2 Children from the Database', () async {

    });


  }); // End of all Children Tests in DatabaseHandler

  // How Widgets would be tested
  //
  //
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  // expect(shouldBeDuration, TypeMatcher<Duration>());

}
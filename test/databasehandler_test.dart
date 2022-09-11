import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/datamodels/itemchild.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  group('Test Classes Item and ItemChild', () {
    test('Test Item -> Set Values and get them all back', () {
      // Arrange
      Item item = Item(5, 'Name');

      // Act
      final int id = item.id;
      final String name = item.name;

      // Assert
      expect(id, 5);
      expect(name, 'Name');
    });
    test('Test ItemChild -> Set Values and get them all back', () {
      // Arrange
      ItemChild item = ItemChild(1, 2, 'description', 25, 'imagepath');

      // Act
      final int id = item.id;
      final int parentID = item.parentID;
      final String description = item.description;
      final double value = item.value;
      final String imagepath = item.imagepath;

      // Assert
      expect(id, 1);
      expect(parentID, 2);
      expect(description, 'description');
      expect(value, 25);
      expect(imagepath, 'imagepath');
    });
  }); // Finished Class testing of Item and ItemChild

  group('Testing all Item methods', () {
    //Testing getItems method
    test('DatabaseHandler method getItems should return 2 valid Items',
        () async {
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([
        {'id': 1, 'name': 'name'},
        {'id': 2, 'name': 'name2'}
      ]);
      when(() => database
              .rawQuery('SELECT * FROM items ORDER BY name COLLATE NOCASE ASC'))
          .thenAnswer((_) async => future);

      // Act
      List<Item> actual = await databaseHandler.getItems();

      // Assert
      expect(actual.length, 2);
    });
    test(
        'This time, getItems should return 1 item inside the List, '
        'because the Database is returning a invalid item in the first row data',
        () async {
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([
        {'id': 1},
        {'id': 2, 'name': 'hi'}
      ]);
      when(() => database
              .rawQuery('SELECT * FROM items ORDER BY name COLLATE NOCASE ASC'))
          .thenAnswer((_) async => future);

      // Act
      List<Item> actual = await databaseHandler.getItems();

      // Assert
      expect(actual.length, 1);
    });

    //Testing getItem method
    test('DatabaseHandler method getItem should return 1 valid Item', () async {
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([
        {'id': 1, 'name': 'name'}
      ]);
      when(() => database.rawQuery('SELECT * FROM items WHERE id = ?', [1]))
          .thenAnswer((_) async => future);

      // Act
      Item actual = await databaseHandler.getItem(1);

      // Assert
      expect(actual.id, 1);
      expect(actual.name, 'name');
    });
    test(
        'This time, getItem should return 1 invalid item, '
        'because the Database is returning a invalid item in the first row data',
        () async {
      // Arrange
      MockDatabase database = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(database);
      final future = Future.value([
        {'id': 1}
      ]);
      when(() => database.rawQuery('SELECT * FROM items WHERE id = ?', [1]))
          .thenAnswer((_) async => future);

      // Act
      Item actual = await databaseHandler.getItem(1);

      // Assert
      expect(actual.id, 0);
      expect(actual.name, '');
    });

    // testing addItem method
    test('addItem should return a value of 1 row affected', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase
              .rawInsert('INSERT INTO items (name) VALUES (?)', ['TestName']))
          .thenAnswer((_) => Future.value(1));

      // Act
      final rowsAffected = await databaseHandler.addItem('TestName');

      // Assert
      expect(rowsAffected, 1);
    });
    test(
        'addItem should return a value of 0 row affected (fake return from DB)',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase
              .rawInsert('INSERT INTO items (name) VALUES (?)', ['TestName']))
          .thenAnswer((_) => Future.value(0));

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
      when(() => mockDatabase.rawDelete('DELETE FROM items WHERE id = ?', [1]))
          .thenAnswer((_) => Future.value(1));

      // Act
      final rowsAffected = await databaseHandler.deleteItem(1);

      // Assert
      expect(rowsAffected, 1);
    });
    test('deleteItem should return 0 row affected because there id no id = 0',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase.rawDelete('DELETE FROM items WHERE id = ?', [0]))
          .thenAnswer((_) => Future.value(0));

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
      when(() => mockDatabase
              .rawDelete('DELETE FROM content WHERE parent = ?', [1]))
          .thenAnswer((_) => Future.value(3));

      // Act
      final int rowsAffected = await databaseHandler.deleteAllChildren(1);

      // Assert
      expect(rowsAffected, 3);
    });
    test('This test should return 0 affected rows (faked DB return)', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase
              .rawDelete('DELETE FROM content WHERE parent = ?', [2]))
          .thenAnswer((_) => Future.value(0));

      // Act
      final int rowsAffected = await databaseHandler.deleteAllChildren(2);

      // Assert
      expect(rowsAffected, 0);
    });

    //test changeItemName
    test(
        'This test should run a query to change the item name and return all affected rows (1)',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase.rawUpdate(
              'UPDATE items SET name = ? WHERE id = ?', ['TestName', 1]))
          .thenAnswer((_) => Future.value(1));

      // Act
      final int rowsAffected =
          await databaseHandler.changeItemName(1, 'TestName');

      // Assert
      expect(rowsAffected, 1);
    });
    test(
        'This test should run a query to change the item name and return all affected rows (0, because there is no id 0)',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      when(() => mockDatabase.rawUpdate(
              'UPDATE items SET name = ? WHERE id = ?', ['TestName', 0]))
          .thenAnswer((_) => Future.value(0));

      // Act
      final int rowsAffected =
          await databaseHandler.changeItemName(0, 'TestName');

      // Assert
      expect(rowsAffected, 0);
    });
  }); // End of Item Tests in DatabaseHandler

  group('Testing all the Children Methods in DatabaseHandler', () {
    // Test getChildren
    test('Should return 2 Children from the Database', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      final databaseValue = Future.value([
        {
          'id': 1,
          'parent': 3,
          'description': 'Description',
          'value': 11.0,
          'imageurl': 'emptypath'
        },
        {
          'id': 2,
          'parent': 3,
          'description': 'Description2',
          'value': 22.0,
          'imageurl': 'emptypath2'
        }
      ]);
      when(() => mockDatabase
              .rawQuery('SELECT * FROM content WHERE parent = ?', [3]))
          .thenAnswer((realInvocation) async => databaseValue);

      // Act
      final List<ItemChild> result = await databaseHandler.getChildren(3);

      //Assert
      expect(result.length, 2);
      ItemChild child = result[0];
      expect(child.id, 1);
      expect(child.parentID, 3);
      expect(child.description, 'Description');
      expect(child.value, 11);
      expect(child.imagepath, 'emptypath');
    });
    test(
        'Should return 1 Child from the Database, because the DB column description is missing in the second',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      final databaseValue = Future.value([
        {
          'id': 1,
          'parent': 3,
          'description': 'Description',
          'value': 11.0,
          'imageurl': 'emptypath'
        },
        {
          'id': 2,
          'parent': 3,
          'value': 22.0,
          'imageurl': 'emptypath2',
        }
      ]); //Missing column here :)
      when(() => mockDatabase
              .rawQuery('SELECT * FROM content WHERE parent = ?', [3]))
          .thenAnswer((realInvocation) async => databaseValue);

      // Act
      final List<ItemChild> result = await databaseHandler.getChildren(3);

      //Assert
      expect(result.length, 1);
      ItemChild child = result[0];
      expect(child.id, 1);
      expect(child.parentID, 3);
      expect(child.description, 'Description');
      expect(child.value, 11);
      expect(child.imagepath, 'emptypath');
    });

    // Test addItemChild Method
    test('addItemChild should return the id of the inserted child', () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(0, 1, 'description', 'imagepath');
      when(() => mockDatabase.rawInsert(
              'INSERT INTO content (parent, description, imageurl) VALUES (?,?,?)',
              [1, 'description', 'imagepath']))
          .thenAnswer((realInvocation) async => Future.value(5));

      // Act
      final int id = await databaseHandler.addItemChild(itemChild);

      //Assert
      expect(id, 5);
    });
    test('addItemChild should return no id -> Item couldn\'t be inserted',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(0, 1, 'description', 'imagepath');
      when(() => mockDatabase.rawInsert(
              'INSERT INTO content (parent, description, imageurl) VALUES (?,?,?)',
              [1, 'description', 'imagepath']))
          .thenAnswer((realInvocation) async => Future.value(0));

      // Act
      final int id = await databaseHandler.addItemChild(itemChild);

      //Assert
      expect(id, 0);
    });

    // Test deleteItemChild
    test(
        'Testing deleteItemChild -> wich should return 1 (means 1 affected row)',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(1, 1, 'description', 'imagepath');
      when(() =>
              mockDatabase.rawDelete('DELETE FROM content WHERE id = ?', [1]))
          .thenAnswer((realInvocation) async => Future.value(1));

      // Act
      final int affectedRows = await databaseHandler.deleteItemChild(itemChild);

      //Assert
      expect(affectedRows, 1);
    });
    test(
        'Testing deleteItemChild -> wich should return 0 (means 0 affected rows)',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(0, 1, 'description', 'imagepath');
      when(() =>
              mockDatabase.rawDelete('DELETE FROM content WHERE id = ?', [0]))
          .thenAnswer((realInvocation) async => Future.value(0));

      // Act
      final int affectedRows = await databaseHandler.deleteItemChild(itemChild);

      //Assert
      expect(affectedRows, 0);
    });

    // Testing updateItemChild
    test(
        'Make sure rawupdate gets called with the right values and 1 row got affected',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(1, 2, 'newDescription', 'newImagepath');
      when(() => mockDatabase.rawUpdate(
              'UPDATE content SET description = ?, imageurl = ? WHERE id = ?',
              ['newDescription', 'newImagepath', 1]))
          .thenAnswer((realInvocation) async => Future.value(1));

      // Act
      final int affectedRows = await databaseHandler.updateItemChild(itemChild);

      //Assert
      expect(affectedRows, 1);
    });
    test(
        'Make sure rawupdate gets called with the right values and 0 row got affected -> with faked DB return',
        () async {
      // Arrange
      MockDatabase mockDatabase = MockDatabase();
      DatabaseHandler databaseHandler = DatabaseHandler(mockDatabase);
      ItemChild itemChild = ItemChild(0, 2, 'newDescription', 'newImagepath');
      when(() => mockDatabase.rawUpdate(
              'UPDATE content SET description = ?, imageurl = ? WHERE id = ?',
              ['newDescription', 'newImagepath', 0]))
          .thenAnswer((realInvocation) async => Future.value(0));

      // Act
      final int affectedRows = await databaseHandler.updateItemChild(itemChild);

      //Assert
      expect(affectedRows, 0);
    });
  }); // End of all Children Tests in DatabaseHandler
}

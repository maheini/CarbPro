import 'package:sqflite/sqflite.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/datamodels/itemchild.dart';

const String databaseName = 'carbpro_db.sqlite';

class DatabaseHandler {

  /// Instance of Itemhandler
  ///
  /// requires a open database to work. The schema should already be implemented
  /// as of now, you can use [addDatabase]
  DatabaseHandler(this._database);

  final Database _database;

  static Future<Database> addDatabase() async {
    return await openDatabase(
      databaseName,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE content(id INTEGER PRIMARY KEY, parent INTEGER, description TEXT, imageurl TEXT)');
        return db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT)',);
      },
      version: 1,
    );
  }

  //---------------------------------------------Item methods-------------------------------------------------

  /// Loads all Items from Database and returns a List of valid ones
  Future<List<Item>> getItems() async {
    List<Item> result = [];

    List<Map> queryResult = await _database.rawQuery('SELECT * FROM items');
    for (var element in queryResult) {
      if (element.containsKey('id') && element.containsKey('name')) {
        Item newItem = Item(element['id']is int ? element['id'] : 0,
            element['name']is String ? element['name'] : '');
        result.add(newItem);
      }
    }
    return result;
  }

  /// Loads a single Item from Database
  Future<Item> getItem(final int id) async {
    List<Map> queryResult = await _database.rawQuery('SELECT * FROM items WHERE id = ?', [id]);
    if(queryResult.isNotEmpty){
      Map element = queryResult[0];
      if (element.containsKey('id') && element.containsKey('name')) {
        return Item(element['id']is int ? element['id'] : 0,
            element['name']is String ? element['name'] : '');
      }
    }
    return Item(0,'');
  }

  /// Insert a new Item to the Database
  /// returns the database id of this new item
  Future<int> addItem(String newName) async {
    final int id = await _database.rawInsert(
        'INSERT INTO items (name) VALUES (?)', [newName]);
    return id;
  }

  /// Deletes item from database and returns the amount of affected rows.
  /// returns the amount of affected rows
  Future<int> deleteItem(int id) async {
    final affectdRows = await _database.rawDelete(
        'DELETE FROM items WHERE id = ?', [id]);
    return affectdRows;
  }

  /// Deletes all childrens of the item with [parentID]
  /// returns the amount of affected rows
  Future<int> deleteAllChildren(final int parentID) async {
    final affectedRows = await _database.rawDelete(
        'DELETE FROM content WHERE parent = ?', [parentID]);
    return affectedRows;
  }

  /// Changed the Item Name and returns the number of affected rows
  Future<int> changeItemName(final int id, final String newName) async {
    final affectedRows = await _database.rawUpdate(
        'UPDATE items SET name = ? WHERE id = ?', [newName, id]);
    return affectedRows;
  }

  //---------------------------------------------Children methods-------------------------------------------------

  /// Loads all ItemChildren from Database and returns a List of valid ones
  Future<List<ItemChild>> getChildren(final int parentID) async {
    List<ItemChild> result = [];

    List<Map> queryResult = await _database.rawQuery('SELECT * FROM content WHERE parent = ?', [parentID]);
    for (var element in queryResult) {
      if (element.containsKey('id') && element.containsKey('description') && element.containsKey('imageurl')) {
        ItemChild newItem = ItemChild(element['id']is int ? element['id'] : 0,
          element['parent']is int ? element['parent'] : 0,
          element['description']is String ? element['description'] : '',
          element['imageurl']is String ? element['imageurl'] : '',
        );
        result.add(newItem);
      }
    }
    return result;
  }

  /// Adds a ItemChild into the Database and returns the new ID
  Future<int> addItemChild(final ItemChild itemChild) async {
    final int newID = await _database.rawInsert('INSERT INTO content (parent, description, imageurl) VALUES (?,?,?)',
        [itemChild.parentID, itemChild.description, itemChild.imagepath]);
    return newID;
  }

  /// Deletes a Child in the Database and returns the amount of affected rows
  Future<int> deleteItemChild(ItemChild itemChild) async {
    final int affectedRows = await _database.rawDelete('DELETE FROM content WHERE id = ?', [itemChild.id]);
    return affectedRows;
  }

  /// Updates the content of an ItemChild inside of the Database and returns the amount of affected rows
  Future<int> updateItemChild(ItemChild itemChild) async {
    final int affestedRows = await _database.rawUpdate('UPDATE content SET description = ?, imageurl = ? WHERE id = ?',
        [itemChild.description, itemChild.imagepath, itemChild.id]);
    return affestedRows;
  }
}
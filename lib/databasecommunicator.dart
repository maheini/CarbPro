import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';



class DatabaseCommunicator {

  ///GET PERMISSIONS AND CLOSE DATABASE
  static Future <Database?> _openDatabase()async{
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        Directory? dir = await getExternalStorageDirectory();
        if (await dir!.exists()) {
          String path = join(dir.path, 'database.db');

          return await openDatabase(
            path,
            onCreate: (db, version) {
              db.execute(
                'CREATE TABLE content(id INTEGER PRIMARY KEY, parent INTEGER, description TEXT, imageurl TEXT)');
              return db.execute(
                'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT)',);
            },
            version: 1,
          );
        }
      }
    }
    return null;
  }

  ///CLOSE DATABASE
  static void _closeDatabase(Database database) {
    database.close();
  }

  ///ADD ITEM AND RETURNS THE ITEM ID
  static Future<int> addItem(String newName) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final int id = await db.rawInsert('INSERT INTO items (name) VALUES (?)', [newName]);
    _closeDatabase(db);
    return id;
  }

  ///REMOVE ITEM AND RETURNS THE AMOUNT OF AFFECTED ROWS
  static Future<int> removeItem(int id) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final count = await db.rawDelete('DELETE FROM items WHERE id = ?',[id]);
    _closeDatabase(db);
    return count;
  }

  ///CHANGE NAME AND RETURNS THE AMOUNT OF AFFECTED ROWS
  static Future<int> changeItemName(int id, String newName) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final count = await db.rawUpdate('UPDATE items SET name = ? WHERE id = ?', [newName, id]);
    _closeDatabase(db);
    return count;
  }

  ///LOADS ALL ITEMS FROM THE DATABASE
  static Future<List<Map>> getItems({String nameFilter = ''}) async {
    Database? db = await _openDatabase();
    if(db == null) return [];

    List<Map> result;
    if(nameFilter.isNotEmpty) {
      result = await db.rawQuery('SELECT * FROM items WHERE name LIKE ? ORDER BY name COLLATE NOCASE ASC', ['%' + nameFilter + '%']);
    }
    else {
      result = await db.rawQuery('SELECT * FROM items WHERE name LIKE ? ORDER BY name COLLATE NOCASE ASC', ['%' + nameFilter + '%']);
    }
    _closeDatabase(db);
    return result;
  }

  ///LOADS ITEM CONTENT FROM DATABASE
  ///first item of the List is the name as String,
  ///second is a List<Map>, containing:
  ///'id' <int>   'description' <String>   'imageurl' <String path>
  static Future<List>getContent({required int parentId}) async {
    Database? db = await _openDatabase();
    if(db == null) return [];

    List<Map> nameQuery = await db.rawQuery('SELECT * FROM items WHERE id = ?', [parentId]);
    if(nameQuery.isEmpty){
      return [];
    }
    List<Map> contentQuery = await db.rawQuery('SELECT * FROM content WHERE parentId = ?', [parentId]);
    _closeDatabase(db);
    return [nameQuery.first['name'].toString(), contentQuery];
  }

  /// ADD ITEM CONTENT
  ///
  /// the file will be copied to a final path, the path should therefore be temporary
  static Future<bool> addItemContent({required int parentId, required String name, File? tempImage}) async{
    Database? db = await _openDatabase();
    if(db == null) return false;

    if(tempImage != null) {
      Directory? dir = await getExternalStorageDirectory();
      if(dir == null) {
        _closeDatabase(db);
        return false;
      }

      final String filename = basename(tempImage.path);
      await tempImage.copy('${dir.path}/$filename');

      if (dir == null){
        _closeDatabase(db);
        return false;
      }
      int id = await db.rawInsert('INSERT INTO content (parent, description, imageurl) VALUES (?, ?, ?)', [parentId, name, filename]);
    }
    else {
      await db.rawInsert('INSERT INTO content (parent, description) VALUES (?, ?)', [parentId, name]);
    }
    _closeDatabase(db);
    return true;
  }


  /// ADD or UPDATES ITEM CONTENT
  ///
  /// the file will be copied to a final path, the path should therefore be temporary
  static Future<bool> updateItemContent({required int id, required String name, File? tempImage}) async{
    Database? db = await _openDatabase();
    if(db == null) return false;

    if(tempImage != null) {
      Directory? dir = await getExternalStorageDirectory();
      if(dir == null) {
        _closeDatabase(db);
        return false;
      }

      final String filename = basename(tempImage.path);
      await tempImage.copy('${dir.path}/$filename');


      if (dir == null){
        _closeDatabase(db);
        return false;
      }

      await db.rawUpdate('UPDATE content SET description = ?, imageurl = ? WHERE id = ?', [name, filename, id]);
    }
    else {
      await db.rawUpdate('UPDATE content SET description = ? WHERE id = ?', [name, id]);
    }
    _closeDatabase(db);
    return true;
  }

  ///REQUESTS ANDROID PERMISSION
  ///true if all is good, otherwhise false
  static Future<bool> _requestPermission(Permission permission) async{
    if(await permission.isGranted) {
      return true;
    }
    else{
      PermissionStatus result = await permission.request();
      if(result.isGranted) {
        return true;
      }
      else {
        return false;
      }
    }
  }
}
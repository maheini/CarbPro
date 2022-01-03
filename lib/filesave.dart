import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class FileSaver extends StatefulWidget {
  const FileSaver({Key? key}) : super(key: key);

  @override
  _FileSaverState createState() => _FileSaverState();
}
class _FileSaverState extends State<FileSaver> {

  //GET PERMISSIONS AND CLOSE DATABASE
  Future <Database?> _openDatabase()async{
    if (Platform.isAndroid) {
      if (await RequestPermission(Permission.storage)) {
        Directory? dir = await getExternalStorageDirectory();
        if (await dir!.exists()) {
          String path = join(dir.path, 'database.db');

          return await openDatabase(
            path,
            onCreate: (db, version) {
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

  //CLOSE DATABASE
  void _closeDatabase(Database database) {
    database.close();
  }

  //ADD ITEM AND RETURNS THE ITEM ID
  Future<int> _addItem(String newName) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final int id = await db.rawInsert('INSERT INTO items (name) VALUES (?)', [newName]);
    _closeDatabase(db);
    return id;
  }

  //REMOVE ITEM AND RETURNS THE AMOUNT OF AFFECTED ROWS
  Future<int> _removeItem(int id) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final count = await db.rawDelete('DELETE FROM items WHERE id = ?',[id]);
    _closeDatabase(db);
    return count;
  }

  //CHANGE NAME AND RETURNS THE AMOUNT OF AFFECTED ROWS
  Future<int> _changeItemName(int id, String newName) async {
    Database? db = await _openDatabase();
    if(db == null) return 0;

    final count = await db.rawUpdate('UPDATE items SET name = ? WHERE id = ?', [newName, id]);
    _closeDatabase(db);
    return count;
  }

  //LOADS ALL ITEMS FROM THE DATABASE
  Future<List<Map>> _getItems() async {
    Database? db = await _openDatabase();
    if(db == null) return [];

    final List<Map> result = await db.rawQuery('SELECT * FROM items');
    _closeDatabase(db);
    return result;
  }

  Future<bool> RequestPermission(Permission permission) async{
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => _addItem('Itemname'),
                child: const Text('Eintrag erstellen'),
            ),
            ElevatedButton(
              onPressed: () => _getItems().then((List<Map>  result) => print(result)),
              child: const Text('Eintrag abrufen'),
            ),
          ],
        )
      ),
    );
  }
}

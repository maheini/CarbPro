import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:meta/meta.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit(this.databaseHandler, this.storageHandler) : super(ListLoading()) {
    databaseHandler.loadDatabase().then((_) => _databaseLoaded = true);
  }
  List<Item> _items = [];
  List<int> _selectedItems = [];
  bool _databaseLoaded = false;
  String? _filter;

  final DatabaseHandler databaseHandler;
  final StorageHandler storageHandler;

  /// load List
  Future<void> loadItems() async {
    emit(ListLoading());
    while (_databaseLoaded == false) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _selectedItems = [];
    _items = await databaseHandler.getItems();
    emit(ListLoaded(_items, _selectedItems));
  }

  /// add or remove [Item] from current selection
  void itemPressed(int index) {
    if (_selectedItems.contains(index)) {
      _selectedItems = [..._selectedItems]..remove(index);
      if (_selectedItems.isEmpty) {
        emit(ListLoaded(_items, _selectedItems));
      } else {
        emit(ListSelection(_items, _selectedItems));
      }
      return;
    } else if (index < _items.length) {
      _selectedItems = [..._selectedItems, index];
      emit(ListSelection(_items, _selectedItems));
    }
  }

  /// clear current selection
  void clearSelection() {
    if (state is ListSelection) {
      _selectedItems = [];
      emit(ListLoaded(_items, _selectedItems));
    }
  }

  /// Adds a new [Item] to the Database if there is none with the same name
  /// !Important: This method is now loading the new [Item] into the list!
  Future<int?> addItem(String name) async {
    if (name.isEmpty) {
      return null;
    }
    if (_items
        .where((element) => element.name.toLowerCase() == name.toLowerCase())
        .isNotEmpty) {
      return _items
          .where((element) => element.name.toLowerCase() == name.toLowerCase())
          .first
          .id;
    }
    return await databaseHandler.addItem(name);
  }

  /// remove all selected [Item]
  /// Calls loadItems() to reload the list after deletion
  Future<bool> deleteSelection() async {
    try {
      if (state is! ListSelection ||
          !await storageHandler.getPermission(
              Permission.storage, PlatformWrapper())) return false;

      Directory dir =
          await storageHandler.getExternalStorageDirectory() ?? Directory('');

      for (var element in _selectedItems) {
        final parentID = _items[element].id;

        List<ItemChild> children = await databaseHandler.getChildren(parentID);
        if (children.isNotEmpty) {
          for (var child in children) {
            final String filepath = '${dir.path}/${child.imagepath}';
            await storageHandler.deleteFile(filepath);
          }
          await databaseHandler.deleteAllChildren(parentID);
        }
        await databaseHandler.deleteItem(parentID);
      }
      loadItems();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Filter all loaded [Items] by [filter]
  void setFilter(String filter) {
    if (state is ListLoading || filter.toLowerCase() == _filter) {
      return;
    }
    _filter = filter.toLowerCase();
    _selectedItems = [];
    List<Item> filteredItems = _items
        .where((element) => element.name.toLowerCase().contains(_filter ?? ''))
        .toList();
    emit(ListFiltered(_filter ?? '', filteredItems, _selectedItems));
  }

  /// Clear the filter and load all [Items]
  void disableFilter() {
    _filter = null;
    emit(ListLoaded(_items, _selectedItems));
  }

  /// Exports all selected [Item] to the external storage
  Future<bool> export() async {
    try {
      if (state is! ListSelection ||
          !await storageHandler.getPermission(
              Permission.manageExternalStorage, PlatformWrapper())) {
        return false;
      }

      String basepath =
          (await storageHandler.getExternalStorageDirectory())?.path ?? '';
      List<File> files = [];
      List<Map<String, dynamic>> itemsJson = [];

      for (var element in _selectedItems) {
        List<Map<String, dynamic>> childrenJson = [];
        List<ItemChild> children =
            await databaseHandler.getChildren(_items[element].id);

        for (ItemChild child in children) {
          files.add(File('$basepath/${child.imagepath}'));
          childrenJson.add({
            'description': child.description,
            'imagepath': child.imagepath,
          });
        }
        Map<String, dynamic> itemJson = {
          'name': _items[element].name,
          'children': childrenJson,
        };

        itemsJson.add(itemJson);
      }

      if (await storageHandler.exportItems(
          jsonEncode(itemsJson), basepath, files, PlatformWrapper())) {
        clearSelection();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> import(FileAccessWrapper fileAccessWrapper) async {
    try {
      // Prepare (load all directorys and permissions)
      Directory? external = await storageHandler.getExternalStorageDirectory();
      Directory? temporary = await storageHandler.getTempStorageDirectory();
      if (external == null || temporary == null) {
        return false;
      }

      // Import all files. If files are null, the import failed
      Directory? files = await storageHandler.import(external, temporary);
      if (files == null) {
        return false;
      }

      // Read content and check if it is a valid json & files
      File itemsFile = File('${files.path}/items.json');
      if (!await fileAccessWrapper.exists(itemsFile)) return false;
      List<dynamic> content =
          jsonDecode(await fileAccessWrapper.readFile(itemsFile) ?? '');
      // check for existance of images
      for (final Map<String, dynamic> item in content) {
        List<dynamic> children = item['children'];
        for (final Map<String, dynamic> child in children) {
          if (await fileAccessWrapper.exists(
            File('${external.path}/${child['imagepath']}'),
          )) {
            return false;
          }
        }
      }

      // Import all files & content to the database
      for (final Map<String, dynamic> item in content) {
        // Map<String, dynamic> item = jsonDecode(element);
        final parentID = await databaseHandler.addItem(item['name']);
        List<dynamic> children = item['children'];

        for (final Map<String, dynamic> child in children) {
          await storageHandler.copyFile('${files.path}/${child['imagepath']}',
              '${external.path}/${child['imagepath']}');
          await databaseHandler.addItemChild(
            ItemChild(
              0,
              parentID,
              child['description'],
              child['imagepath'],
            ),
          );
        }
      }

      // reload and finish
      loadItems();
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:meta/meta.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:equatable/equatable.dart';

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

  /// remove all selected [Item]
  /// Calls loadItems() to reload the list after deletion
  Future<void> deleteSelection() async {
    if (state is ListSelection) {
      if (!await storageHandler.getPermission(
          Permission.storage, PlatformWrapper())) return;

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
    }
    loadItems();
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
}

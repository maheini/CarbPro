import 'package:bloc/bloc.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:meta/meta.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:equatable/equatable.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit(this.databaseHandler) : super(ListLoading()) {
    databaseHandler.loadDatabase().then((_) => _databaseLoaded = true);
  }
  List<Item> _items = [];
  List<int> _selectedItems = [];
  bool _databaseLoaded = false;

  final DatabaseHandler databaseHandler;

  /// load List
  Future<void> loadItems() async {
    emit(ListLoading());
    while (_databaseLoaded == false) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _items = await databaseHandler.getItems();
    emit(ListLoaded(_items, _selectedItems));
  }

  itemPressed(int index) {
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
}

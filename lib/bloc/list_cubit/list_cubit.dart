import 'package:bloc/bloc.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:meta/meta.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:equatable/equatable.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit(this.databaseHandler) : super(ListLoading());
  List<Item> _items = [];
  final List<int> _selectedItems = [];

  final DatabaseHandler databaseHandler;

  /// load List
  Future<void> loadItems() async {
    emit(ListLoading());
    _items = await databaseHandler.getItems();
    emit(ListLoaded(_items, _selectedItems));
  }

  itemPressed(int index) {
    if (_selectedItems.remove(index)) {
      if (_selectedItems.isEmpty) {
        emit(ListLoaded(_items, _selectedItems));
      } else {
        emit(ListSelection(_items, _selectedItems));
      }
      return;
    } else if (index < _items.length) {
      _selectedItems.add(index);
      emit(ListSelection(_items, _selectedItems));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:meta/meta.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:equatable/equatable.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit(this.databaseHandler) : super(ListLoading());
  List<Item> _items = [];
  List<int> _selectedItems = [];

  final DatabaseHandler databaseHandler;

  /// load List
  Future<void> loadItems() async {
    emit(ListLoading());
    _items = await databaseHandler.getItems();
    emit(ListLoaded(_items, _selectedItems));
  }

  itemPressed(int index) async {}

  List<Object> get props => [_items, _selectedItems];
}

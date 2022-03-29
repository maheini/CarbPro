part of 'list_cubit.dart';

@immutable
abstract class ListState extends Equatable {
  const ListState(this.items, this.selectedItems);
  final List<Item> items;
  final List<int> selectedItems;
}

class ListLoading extends ListState {
  ListLoading() : super([], []);
  @override
  List<Object> get props => [];
}

class ListLoaded extends ListState {
  const ListLoaded(List<Item> items, List<int> selectedItems)
      : super(items, selectedItems);

  @override
  List<Object> get props => [super.items, super.selectedItems];
}

class ListSelection extends ListState {
  const ListSelection(List<Item> items, List<int> selectedItems)
      : super(items, selectedItems);

  @override
  List<Object> get props => [super.items, super.selectedItems];
}

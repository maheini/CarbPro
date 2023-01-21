part of 'list_cubit.dart';

@immutable
abstract class ListState extends Equatable {
  const ListState(this.items, this.selectedIds);
  final List<Item> items;
  final List<int> selectedIds;
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
  List<Object> get props => [super.items, super.selectedIds];
}

class ListFiltered extends ListState {
  const ListFiltered(this.filter, List<Item> items, List<int> selectedItems)
      : super(items, selectedItems);

  final String filter;
  @override
  List<Object> get props => [filter, super.items, super.selectedIds];
}

class ListSelection extends ListState {
  const ListSelection(List<Item> items, List<int> selectedItems)
      : super(items, selectedItems);

  @override
  List<Object> get props => [super.items, super.selectedIds];
}

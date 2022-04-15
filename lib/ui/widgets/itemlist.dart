import 'package:flutter/material.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carbpro/generated/l10n.dart';

import '../../datamodels/item.dart';

class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListCubit, ListState>(
      // no need to rebuild if state is listselection
      //    -> selection only affects single tiles, so nothing to do then
      buildWhen: (previous, current) => (current is! ListSelection),
      builder: (context, state) {
        if (state is ListLoaded ||
            state is ListSelection ||
            state is ListFiltered) {
          // update state, because state of buildwhen isn't accurate
          state = context.read<ListCubit>().state;
          return Material(
            child: ListView.separated(
                controller: _scrollController,
                itemBuilder: (context, index) =>
                    _generateTile(context, index, state.items[index]),
                separatorBuilder: (context, index) {
                  return const Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    height: 5,
                  );
                },
                itemCount: state.items.length),
          );
        } else if (state is ListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: Text(S.current.unknown_error),
          );
        }
      },
    );
  }

  Widget _generateTile(BuildContext context, int index, Item item) {
    return BlocSelector<ListCubit, ListState, bool>(
      selector: ((state) {
        return state.selectedItems.contains(index);
      }),
      builder: (context, isSelected) {
        return ListTile(
          selected: isSelected,
          selectedColor: Colors.black,
          selectedTileColor: Colors.blue.shade100,
          title: Text(item.name),
          onTap: () {
            if (context.read<ListCubit>().state is ListSelection) {
              context.read<ListCubit>().itemPressed(index);
            } else {
              Navigator.pushNamed(context, '/details', arguments: item.id);
            }
          },
          onLongPress: () {
            context.read<ListCubit>().itemPressed(index);
          },
        );
      },
    );
  }
}

import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/ui/widgets/itemlist.dart';
import 'package:flutter/material.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carbpro/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.listCubit}) : super(key: key);

  final ListCubit? listCubit;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ListCubit _listCubit;

  @override
  void initState() {
    _listCubit = widget.listCubit ?? ListCubit(locator<DatabaseHandler>());
    _listCubit.loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _listCubit,
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              if (context.read<ListCubit>().state is ListFiltered) {
                context.read<ListCubit>().disableFilter();
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              appBar: _appBar(context),
              body: const ItemList(),
              floatingActionButton: BlocBuilder<ListCubit, ListState>(
                builder: (context, state) {
                  if (state is ListLoading) {
                    return const SizedBox();
                  } else {
                    return FloatingActionButton(
                      onPressed: _addItem,
                      child: const Icon(Icons.add, color: Colors.white),
                      backgroundColor: Colors.indigo,
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSize _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      child: BlocBuilder<ListCubit, ListState>(
        builder: (context, state) {
          if (state is ListLoading) {
            return AppBar(
              title: const Text('CarbPro'),
            );
          } else if (state is ListFiltered) {
            return _buildSearchBar(context);
          } else {
            return _buildDefaultBar(context);
          }
        },
      ),
    );
  }

  AppBar _buildDefaultBar(BuildContext context) {
    return AppBar(
      title: const Text('CarbPro'),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: () {
            context.read<ListCubit>().setFilter('');
          },
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  AppBar _buildSearchBar(BuildContext context) {
    return AppBar(
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        child: Center(
          child: TextField(
            autofocus: true,
            onChanged: (text) => context.read<ListCubit>().setFilter(text),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () => context.read<ListCubit>().disableFilter(),
                ),
                hintText: S.of(context).search,
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  // TODO: Implement add functionality
  void _addItem() {}

  // TODO: Add delete functionality
  // TODO final: Add export functionality
  // TODO: clean up code
}

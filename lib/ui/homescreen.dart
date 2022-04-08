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
  late ListCubit listCubit;

  @override
  void initState() {
    listCubit = widget.listCubit ?? ListCubit(locator<DatabaseHandler>());
    listCubit.loadItems();
    super.initState();
  }

  bool _search = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => listCubit,
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              if (_search) {
                setState(() => _search = false);
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(AppBar().preferredSize.height),
                child: BlocBuilder<ListCubit, ListState>(
                  builder: (context, state) {
                    if (state is ListLoading) {
                      return AppBar(
                        title: const Text('CarbPro'),
                      );
                    } else {
                      return _search
                          ? AppBar(
                              title: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3)),
                                child: Center(
                                  child: TextField(
                                    autofocus: true,
                                    onChanged: (_) => setState(() {}),
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.blueGrey,
                                          ),
                                          onPressed: () =>
                                              setState(() => _search = false),
                                        ),
                                        hintText: S.of(context).search,
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                            )
                          : AppBar(
                              title: const Text('CarbPro'),
                              centerTitle: true,
                              actions: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _search = true);
                                  },
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                    }
                  },
                ),
              ),
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

  void _addItem() {}
}

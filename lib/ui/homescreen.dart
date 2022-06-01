import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
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
  HomeScreenState createState() => HomeScreenState();
}

@visibleForTesting
class HomeScreenState extends State<HomeScreen> {
  late ListCubit _listCubit;

  @visibleForTesting
  final PlatformWrapper platformWrapper = PlatformWrapper();

  @override
  void initState() {
    _listCubit = widget.listCubit ??
        ListCubit(locator<DatabaseHandler>(), locator<StorageHandler>());
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
              } else if (context.read<ListCubit>().state is ListSelection) {
                context.read<ListCubit>().clearSelection();
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
                      onPressed: () => _addItem(context),
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
          } else if (state is ListSelection) {
            return _buildSelectBar(context);
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
        _popupMenu(context),
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
            cursorColor: Colors.grey[200],
            autofocus: true,
            onChanged: (text) => context.read<ListCubit>().setFilter(text),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[200],
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

  AppBar _buildSelectBar(BuildContext context) {
    return AppBar(
      title: Text(
        S.of(context).items_selected(
            context.read<ListCubit>().state.selectedItems.length),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (!await context.read<ListCubit>().deleteSelection()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).error_deleting_item),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () async {
            context.read<ListCubit>().export().then((bool successful) {
              if (successful) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).export_success),
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).export_failure),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            });
          },
          icon: const Icon(Icons.archive),
        ),
      ],
    );
  }

  void _addItem(BuildContext context) async {
    TextEditingController _controller = TextEditingController();
    bool textEmptyError = false;
    final input = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(S.of(context).add_item),
              content: TextField(
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: S.of(context).name,
                  errorText: textEmptyError ? S.of(context).name_empty : null,
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: Text(S.of(context).cancel.toUpperCase())),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isEmpty) {
                      setState(() => textEmptyError = true);
                    } else {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  child: Text(S.of(context).add.toUpperCase()),
                ),
              ],
            );
          },
        );
      },
    );

    if (input.toString().isNotEmpty) {
      final int? id = await context.read<ListCubit>().addItem(input);
      if (id != null) {
        Navigator.pushNamed(context, '/details', arguments: id)
            .then((value) => context.read<ListCubit>().loadItems());
      }
    }
  }

  Widget _popupMenu(BuildContext context) {
    return PopupMenuButton(
      onSelected: (result) async {
        if (result == 1) {
          context.read<ListCubit>().import(FileAccessWrapper()).then(
            (value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).import_failure),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          );
        } else if (result == 2) {
          Navigator.pushNamed(context, '/about');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          child: _buildPopupItem(Icons.unarchive, S.of(context).import),
          value: 1,
        ),
        PopupMenuItem(
          child: _buildPopupItem(Icons.info, S.of(context).about),
          value: 2,
        ),
      ],
    );
  }

  Widget _buildPopupItem(IconData icon, String name) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        const SizedBox(width: 5),
        Text(name),
      ],
    );
  }

  // TODO: clean up code
}

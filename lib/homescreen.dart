import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter/material.dart';
import 'locator/locator.dart';
import 'datamodels/item.dart';
import 'datamodels/itemchild.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    awaitLocatorSetup();
  }

  void awaitLocatorSetup() async {
    await locator.allReady();
    _loadAndDisplayItems();
  }

  void _loadAndDisplayItems() async {
    _items = await locator<DatabaseHandler>().getItems();
    setState(() {
      _isLoading = false;
    }); // hides loader and rebuilding everything with the new list
  }

  List<Item> _items = [];

  Widget _itemList({String? filter, required List<Item> list}) {
    late final List<Item> items;
    if (filter == null) {
      items = list;
    } else {
      items = list.where((element) => element.name.contains(filter)).toList();
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index].name),
          onTap: () {
            Navigator.pushNamed(context, '/details', arguments: items[index].id)
                .then((value) => _loadAndDisplayItems());
          },
          onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Bestätigen"),
                content:
                    const Text("Möchtest du des Element wirklich entfernen?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("ABBRECHEN"),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("ENTFERNEN")),
                ],
              );
            },
          ).then((removeConfirmation) async {
            if (removeConfirmation) {
              final parentID = items[index].id;
              List<ItemChild> images =
                  await locator<DatabaseHandler>().getChildren(parentID);
              if (images.isNotEmpty) {
                if (!await locator<StorageHandler>()
                    .getPermission(Permission.storage, PlatformWrapper())) {
                  // todo: add alertdialog
                  return;
                } else {
                  for (var element in images) {
                    locator<StorageHandler>().deleteFile(element.imagepath);
                  }
                  await locator<DatabaseHandler>().deleteAllChildren(parentID);
                }
              }
              await locator<DatabaseHandler>().deleteItem(parentID);
              _loadAndDisplayItems();
            }
          }),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          indent: 10,
          endIndent: 10,
          thickness: 1,
          height: 5,
        );
      },
      itemCount: items.length,
    );
  }

  //UI BUILDER
  bool _isLoading = true;
  bool _search = false; //SEARCH BAR CONTROL AND CONTROLLER
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
        appBar: _isLoading
            ? AppBar(
                title: const Text('CarbPro'),
              )
            : _search
                ? AppBar(
                    title: Container(
                    width: double.infinity,
                    height: 40,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(3)),
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
                              onPressed: () => setState(() => _search = false),
                            ),
                            hintText: 'Suchen',
                            border: InputBorder.none),
                      ),
                    ),
                  ))
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
                          )),
                    ],
                  ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _itemList(
                list: _items, filter: _search ? _searchController.text : null),
        floatingActionButton: _isLoading
            ? null
            : FloatingActionButton(
                onPressed: _addItem,
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: Colors.indigo,
              ),
      ),
    );
  }

  //ADD ITEM POPUP
  void _addItem() async {
    TextEditingController _controller = TextEditingController();
    bool textEmptyError = false;
    final input = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Artikel einfügen'),
                content: TextField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    errorText: textEmptyError ? 'Name ist leer' : null,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context, _controller.text),
                      child: const Text('ABBRECHEN')),
                  TextButton(
                      onPressed: () {
                        if (_controller.text.isEmpty) {
                          setState(() => textEmptyError = true);
                        } else {
                          Navigator.pop(context, _controller.text);
                        }
                      },
                      child: const Text('ERSTELLEN')),
                ],
              );
            },
          );
        });

    int existingDBid = 0;
    if (input.toString().isNotEmpty) {
      bool alreadyExists = false;
      for (Item element in _items) {
        if (element.name.toLowerCase() == input.toString().toLowerCase()) {
          existingDBid = element.id;
          alreadyExists = true;
          break;
        }
      }

      if (!alreadyExists) {
        final int id = await locator<DatabaseHandler>().addItem(input);
        Navigator.pushNamed(context, '/details', arguments: id)
            .then((value) => _loadAndDisplayItems());
      } else {
        Navigator.pushNamed(context, '/details', arguments: existingDBid)
            .then((value) => _loadAndDisplayItems());
      }
    }
  }
}

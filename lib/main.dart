import 'package:flutter/material.dart';
import 'databasecommunicator.dart';
import 'detailscreen.dart';
import 'filesave.dart';

void main() =>runApp(MaterialApp(
    // home: FileSaver(),
    // )
  routes: {
    '/': (context) => MyApp(),
    '/details': (context) => DetailScreen(),
  },
  theme: ThemeData.dark(),
  title: 'CarbPro',
)
);


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //UI BUILDER
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _search?
      AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3)),
            child: Center(
              child: TextField(
                autofocus: true,
                onChanged: (String input) {setState(() {});},
                controller: _searchController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.blueGrey,),
                      onPressed: () => _setSearch(false),
                    ),
                    hintText: 'Suchen',
                    border: InputBorder.none
                ),
              ),
            ),
          )
      ):
      AppBar(
        title: Text('CarbPro'),
        actions: <Widget>[
          IconButton(onPressed: () {_setSearch(true);}, icon: Icon(Icons.search, color: Colors.white,)),
        ],
      ),
      body: _makeList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _AddItem(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  //LIST GENERATER
  void _loadItems() async {
    _items = await DatabaseCommunicator.getItems();
    setState(() {_reloadItems = false;});
  }
  List<Map> _items = [];
  bool _reloadItems = true;
  Widget _makeList({String filter = ''})
  {
    if(_reloadItems) _loadItems();

    List<Map> items = [];
    _search? _items.forEach((element) {if(element['name'].toString().contains(_searchController.text)) items.add(element);}):
             items = _items;

    return ListView.separated(
      itemBuilder: (context, index) {
        final Map item = items[index];
        return Dismissible(
          key: Key(item['name']),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Bestätigen"),
                  content: const Text("Möchtest du des Element wirklich entfernen?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("ENTFERNEN")
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("ABBRECHEN"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            DatabaseCommunicator.removeItem(item['id']).then((value) => _loadItems());
          },
          background: Container( padding: EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.centerRight, color: Colors.red, child: Icon(Icons.remove_circle),),
          child: ListTile(
            title: Text(item['name'].toString()),
            onTap: () {Navigator.pushNamed(context, '/details');},
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(indent: 10, endIndent: 10, thickness: 1, height: 5,);
      },
      itemCount: items.length,
    );
  }
  
  //SEARCH BAR CONTROL
  bool _search = false;
  final TextEditingController _searchController = TextEditingController();
  //SEARCH EN-/DISABLE
  void _setSearch(bool enabled)
  {
    _search = enabled;
    _searchController.clear();
    setState(() {
    });
  }

  //ADD ITEM POPUP
  void _AddItem(BuildContext context) async {
    TextEditingController _controller = TextEditingController();
    bool _TextEmptyError = false;
    final input = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Artikel einfügen'),
              content: TextField(
                onSubmitted: (String text) {
                  if (_controller.text.isEmpty)
                    setState(() {
                      _TextEmptyError = true;
                    });
                  else
                    Navigator.pop(context, _controller.text);
                },
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Name',
                  errorText: _TextEmptyError?'Name ist leer':null,
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ABBRECHEN')
                ),
                TextButton(
                    onPressed: () {
                      if (_controller.text.isEmpty)
                        setState(() {_TextEmptyError = true;});
                      else
                        Navigator.pop(context, _controller.text);
                    },
                    child: const Text('ERSTELLEN')
                ),
              ],
            );
          },
        );
      }
    );

    if(input.toString().isNotEmpty) {
      bool alreadyExists = false;
      for (var element in _items) {
        if (element['name'].toString().toLowerCase() ==
            input.toString().toLowerCase()) {
          alreadyExists = true;
          break;
        }
      }
      if (!alreadyExists) {
        DatabaseCommunicator.addItem(input).then((value) =>
            Navigator.pushNamed(context, '/details').then((value) => _loadItems()));
      }
      else {
        Navigator.pushNamed(context, '/details').then((value) => _loadItems());
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'detailscreen.dart';
import 'databasecommunicator.dart';
import 'package:get_it/get_it.dart';
import 'handler/databasehandler.dart';
import 'handler/storagehandler.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
  runApp(
    MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          return MaterialPageRoute(builder: (_) => DetailScreen(id: settings.arguments as int)); // Pass it to BarPage.
        }
        else if (settings.name == '/'){
          return MaterialPageRoute(builder: (_) => const CarbPro());
        }
        return null; // Let `onUnknownRoute` handle this behavior.
      },
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      title: 'CarbPro',
    ),
  );
}

class CarbPro extends StatefulWidget {
  const CarbPro({Key? key}) : super(key: key);

  @override
  _CarbProState createState() => _CarbProState();
}

class _CarbProState extends State<CarbPro> {

  @override
  void initState() {
    prepareApp();
    super.initState();
  }

  @visibleForTesting
  bool databaseIsOpen = false;
  @visibleForTesting
  bool hasFilePermission = false;
  void prepareApp() async {
    hasFilePermission = await requestFilePermission();
    if(hasFilePermission){
      databaseIsOpen = await openDatabase();
    }
  }

  Future<bool> requestFilePermission() async {
    return false;
  }

  Future<bool> openDatabase() async {
    return false;
  }

  Widget requestPermissionContainer({VoidCallback? onRequestPressed}){
    return Center(
      child: Column(
        children: [
          Title(color: Colors.grey[850]!, child: const Text('Berechtigung fehlt')),
          const Text('Die Berechtigung für den Speicher wird benötigt '
              'um Bilder und Daten auf dem Gerät zu speichern.'),
          ElevatedButton(
            onPressed: onRequestPressed,
            child: const Text('Berechtigung anfragen'),
          ),
        ],
      ),
    );
  }

  //UI BUILDER
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_search){
          setState(() => _setSearch(false));
          return false;
        }
        else {
          return true;
        }},
      child: Scaffold(
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
                  onChanged: (input) => _loadItems(),
                  controller: _searchController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.blueGrey,),
                        onPressed: () => _setSearch(false),
                      ),
                      hintText: 'Suchen',
                      border: InputBorder.none
                  ),
                ),
              ),
            )
        ) :
        AppBar(
          title: const Text('CarbPro'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(onPressed: () {_setSearch(true);}, icon: const Icon(Icons.search, color: Colors.white,)),
          ],
        ),
        body: _makeList(),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  //LIST GENERATOR
  void _loadItems() async {
    if(_search){
      _items = await DatabaseCommunicator.getItems(nameFilter:  _searchController.text);
    }
    else {
      _items = await DatabaseCommunicator.getItems();
    }
    setState(() {_reloadItems = false;});
  }
  List<Map> _items = [];
  bool _reloadItems = true;
  Widget _makeList()
  {
    if(_reloadItems) _loadItems();

    return ListView.separated(
      itemBuilder: (context, index) {
        final Map item = _items[index];
        return ListTile(
          title: Text(item['name'].toString()),
          onTap: () {
            Navigator.pushNamed(context, '/details', arguments: item['id'])
                .then((value) => _setSearch(false));},
          onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Bestätigen"),
                content: const Text("Möchtest du des Element wirklich entfernen?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("ABBRECHEN"),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("ENTFERNEN")
                  ),
                ],
              );
            },
          ).then((removeConfirmation) {
            if(removeConfirmation){
              DatabaseCommunicator.removeItem(item['id']).then((value) => _loadItems());
            }
          }),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(indent: 10, endIndent: 10, thickness: 1, height: 5,);
      },
      itemCount: _items.length,
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
    _loadItems();
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
                  onSubmitted: (String text) {
                    if (_controller.text.isEmpty) {
                      setState(() {
                        textEmptyError = true;
                      });
                    } else {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    errorText: textEmptyError?'Name ist leer':null,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ABBRECHEN')
                  ),
                  TextButton(
                      onPressed: () {
                        if (_controller.text.isEmpty) {setState(() => textEmptyError = true);}
                        else {Navigator.pop(context, _controller.text);}
                      },
                      child: const Text('ERSTELLEN')
                  ),
                ],
              );
            },
          );
        }
    );

    int existingDBid = 0;
    final List<Map> allItems = await DatabaseCommunicator.getItems();
    if(input.toString().isNotEmpty) {
      bool alreadyExists = false;
      for (var element in allItems) {
        if (element['name'].toString().toLowerCase() ==
            input.toString().toLowerCase()) {
          existingDBid = element['id'];
          alreadyExists = true;
          break;
        }
      }
      if (!alreadyExists) {
        final int id = await DatabaseCommunicator.addItem(input);
        Navigator.pushNamed(context, '/details', arguments: id)
            .then((value) => _setSearch(false));
      }
      else {
        Navigator.pushNamed(context, '/details', arguments: existingDBid)
            .then((value) => _setSearch(false));
      }
    }
  }


}

import 'package:carb_sy/databasecommunicator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class DetailScreen extends StatefulWidget {


  final int id;
  const DetailScreen({required this.id});



  @override
  _DetailScreenState createState() => _DetailScreenState();
}


class _DetailScreenState extends State<DetailScreen> {

  //CONTENT MANAGEMENT
  String _itemName = '';
  List<Map> content = [];
  void _loadContent() async{
    List result = await DatabaseCommunicator.getContent(id: widget.id);
    if(result.isEmpty) {
      return;
    }
    _itemName = result[1];
    content = result[2];

    setState(() {});
  }



  // final item = DatabaseCommunicator()
  Widget _createImage(int index) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Hallo'),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Center(
              child: Text('hi $_ItemCount'),
            ),
          )
        ],
      ),
    );
  }

  int _ItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_itemName), centerTitle: true, actions: [IconButton(icon: Icon(Icons.edit), onPressed: _editName,)],),
      floatingActionButton: FloatingActionButton(onPressed: () {setState(() {_ItemCount++;});}, child: Icon(Icons.add_a_photo),),
      body: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: List<Widget>.generate(_ItemCount, (index) {
            return _createImage(index);
          })
      ),
    );
  }

  void _AddPicture() async {
    if (Platform.isAndroid) {
      if (await _GetPermssion(Permission.camera)) {

      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Fehler'),
                content: Text('Die Berechtigung für die Kamera fehlt'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'ok'),
                    child: Text('OK'),
                  ),
                ],
              );
            }
        );
      }
    }
    else {
      print('Plattform nicht unterstützt....');
    }
  }

  Future<bool> _GetPermssion(Permission permission) async{
    PermissionStatus status = await permission.status;
    if(status.isGranted){
      return true;
    }
    else if (await permission.request().isGranted){
      return true;
    }
    return false;
  }


  //EDIT ITEM NAME
  void _editName() async {
    TextEditingController _controller = TextEditingController(text: _itemName);
    bool textEmptyError = false;
    final input = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Artikel bearbeiten'),
              content: TextField(
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
                  errorText: textEmptyError ? 'Name ist leer' : null,
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ABBRECHEN')
                ),
                TextButton(
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        setState(() => textEmptyError = true);
                      }
                      else {
                        Navigator.pop(context, _controller.text);
                      }
                    },
                    child: const Text('SPEICHERN')
                ),
              ],
            );
          },
        );
      }
    );

    // if(input.toString().isNotEmpty) {
    //   bool alreadyExists = false;
    //   for (var element in _items) {
    //     if (element['name'].toString().toLowerCase() ==
    //         input.toString().toLowerCase()) {
    //       alreadyExists = true;
    //       break;
    //     }
    //   }
    //   if (!alreadyExists) {
    //     DatabaseCommunicator.addItem(input).then((value) =>
    //         Navigator.pushNamed(context, '/details').then((value) => _loadItems()));
    //   }
    //   else {
    //     Navigator.pushNamed(context, '/details').then((value) => _loadItems());
    //   }
    // }
  }
}
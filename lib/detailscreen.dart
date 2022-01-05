import 'package:carbpro/databasecommunicator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({Key? key, required this.id}) : super(key:key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}


class _DetailScreenState extends State<DetailScreen> {
  bool _loadContentOnNextBuild = true;
  @override
  Widget build(BuildContext context) {
    if(_loadContentOnNextBuild) {
      _loadContent();
      _loadContentOnNextBuild = false;
    }
    return Scaffold(
      appBar: AppBar(title: Text(_itemName), centerTitle: true, actions: [IconButton(icon: Icon(Icons.edit), onPressed: _editName,)],),
      floatingActionButton: FloatingActionButton(onPressed: () {setState(() {_itemCount++;});}, child: Icon(Icons.add_a_photo),),
      body: GridView.count(
          crossAxisCount: 2,
          children: List<Widget>.generate(_itemCount, (index) {
            return _createImage(index);
          })
      ),
    );
  }

  //CONTENT MANAGEMENT
  String _itemName = '';
  List<Map> content = [];
  void _loadContent() async{
    List result = await DatabaseCommunicator.getContent(id: widget.id);
    if(result.isEmpty) {
      return;
    }
    _itemName = result[0];
    content = result[1];
    setState(() {});
  }

  // final item = DatabaseCommunicator()
  Widget _createImage(int index) {
    return InkWell(
      onTap: null, //Todo Add editable Popup here
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),borderRadius: BorderRadius.all(Radius.circular(4))),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 17,
              child: Container(
                alignment: Alignment.center,
                child: Text('Bild'),
                decoration: BoxDecoration(border: Border.all(width: 1)),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Flexible(
              flex: 3,
              child: Container(
                child: Text('Beschreibung'),
                decoration: BoxDecoration(border: Border.all(width: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  int _itemCount = 0;


  void _addPicture() async {
    if (Platform.isAndroid) {
      if (await _getPermission(Permission.camera)) {

      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Fehler'),
                content: const Text('Die Berechtigung für die Kamera fehlt'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'ok'),
                    child: const Text('OK'),
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

  Future<bool> _getPermission(Permission permission) async{
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

    if(input != _itemName){
      DatabaseCommunicator.changeItemName(widget.id, _controller.text)
          .then((value) =>_loadContent());
    }
  }
}
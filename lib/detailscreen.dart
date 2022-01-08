import 'dart:core';

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

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _loadListContent();
  }

  //UI BUILDER
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_itemName), centerTitle: true, actions: [IconButton(icon: Icon(Icons.edit), onPressed: _editName,)],),
      floatingActionButton: FloatingActionButton(onPressed: () => _itemEditor(newitem: true), child: Icon(Icons.add_a_photo),),
      body: GridView.count(
        crossAxisCount: 2,
        children: _generatedContentItems,
      ),
    );
  }

  //CREATE LIST
  String _itemName = '';
  List<Map> _content = [];
  List<Widget> _generatedContentItems = [];
  //CREATE LIST
  Future<Widget> _createListTile(int index, bool hasImageReadPermission) async{

    File file = File(_content[index]['imageurl']);
    if(!await file.exists()){
      hasImageReadPermission = false;
    }

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),borderRadius: BorderRadius.all(Radius.circular(4))),
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onLongPress: () async {
          bool remove = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Bestätigen"),
                content: const Text("Möchtest du den Eintrag wirklich entfernen?"),
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
          );

          if(remove){
            //todo implement remove method and setstate for the content.
          }
        },
        onTap: _addPicture,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 17,
                child: Container(
                  alignment: Alignment.center,
                  child: hasImageReadPermission? Image.file(file) : const Icon(Icons.wallpaper),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Flexible(
                flex: 3,
                child: Container(
                  child: Text(_content[index]['name']),
                ),
              )
            ],
          ),
        )
      )
    );
  }
  void _loadListContent() async{
    //CHECK PERMISSION FOR ACCESSING IMAGE FILEPATH'S FOR LIST-GENERATION AND DB ACCESS
    final bool imageReadPermission = await _getPermission(Permission.storage);
    if(!imageReadPermission){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Fehler'),
              content: const Text('Die Berechtigung für den Speicherzugriff fehlt'),
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

    List result = await DatabaseCommunicator.getContent(id: widget.id);
    if(result.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Fehler'),
              content: const Text('Unbekannter Datenbankfehler'),
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
    _itemName = result[0];
    _content = result[1];

    //GENERATE LIST WITH IMAGES AND THEIR DESCRIPTION
    List<Widget> _tempContentList = [];
    for(int x=0; x<_content.length; x++)
      {
        _tempContentList.add(await _createListTile(x, imageReadPermission));
      }
    _generatedContentItems = _tempContentList;

    //NOW SHOW ALL THOSE CHANGES...
    setState(() {});
  }


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

  //EDIT ITEM
  void _itemEditor({bool newitem = false, Image? image, String text = ''}) async {
    TextEditingController itemNameController = TextEditingController(text: text);
    bool textEmptyError = false;
    bool nameEditingLocked = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _addPicture,
                      child: AspectRatio(
                        //todo add function for camera and database update / insert
                        aspectRatio: 1,
                          child: image ?? const Icon(Icons.add_photo_alternate_outlined, size: 50,),
                      ),
                    ),
                    TextField(
                      autofocus: true,
                      readOnly: nameEditingLocked,
                      controller: itemNameController,
                      decoration: InputDecoration(
                        hintText: 'Beschreibung',
                        errorText: textEmptyError ? 'Beschreibung ist leer' : null,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => nameEditingLocked = !nameEditingLocked),
                          icon: Icon(nameEditingLocked?Icons.edit:Icons.done),
                        ),
                      ),
                      onChanged: (String input) {
                        if(itemNameController.text.isEmpty) {
                          setState(() {textEmptyError = true;});
                        }
                        else if (textEmptyError) {
                          setState(() {textEmptyError = false;});
                        }
                      },
                      onSubmitted: (String text) => setState(() => nameEditingLocked = !nameEditingLocked),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ABBRECHEN')
                ),
                TextButton(
                    onPressed: () {
                      if (itemNameController.text.isEmpty && image == null) {
                        Navigator.pop(context);
                      }
                      else {
                        //Todo add function for adding / save new item.
                        Navigator.pop(context);
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
  }


  //EDIT ITEM NAME ->Main purpose: show Details of an Item, let the user edit them and
  //    provide a possibility for adding new items.
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

    if(input != _itemName){     //NAME CHANGED? THEN SAVE AND RELOAD NAME&UI
      await DatabaseCommunicator.changeItemName(widget.id, _controller.text);
      List result = await DatabaseCommunicator.getContent(parentId: widget.id);
      if(result.isEmpty) {
        return;
      }
      _itemName = result[0];
      setState(() {});
    }
  }
}
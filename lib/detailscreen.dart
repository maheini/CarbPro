import 'dart:core';

import 'package:carbpro/databasecommunicator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'datamodels/item.dart';
import 'datamodels/itemchild.dart';
import 'locator/locator.dart';
import 'handler/databasehandler.dart';
import 'handler/storagehandler.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({Key? key, required this.id}) : super(key:key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}


class _DetailScreenState extends State<DetailScreen> {
  Item _item = Item (0 ,'');
  List<ItemChild> _itemChildren = [];
  
  List<Map> _content = [];
  List<Widget> _generatedContentItems = [];

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _loadFullContent();
  }

  void _loadFullContent() async {
    await _loadItemContent();
    await _loadItemChildren();
    setState(() {});
  }

  Future<void> _loadItemContent() async {
    _item = await locator<DatabaseHandler>().getItem(widget.id);
  }

  Future<void> _loadItemChildren() async {
    _itemChildren = await locator<DatabaseHandler>().getChildren(widget.id);
  }

  //UI BUILDER
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item.name), centerTitle: true, actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _editName,)],),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _itemEditor(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.white,),),
      body: GridView.count(
        childAspectRatio: 32/37,
        crossAxisCount: 2,
        children: _generatedContentItems,
      ),
    );
  }


  //LOAD ALL VALUES OF THIS ITEM AND SET NEW STATE
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
    List result = await DatabaseCommunicator.getContent(parentId: widget.id);
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

  //CREATE LIST TILE
  Future<Widget> _createListTile(int index, bool hasImageReadPermission) async{

    Directory dir = await getExternalStorageDirectory() ?? Directory('');

    File file = File('${dir.path}/${_content[index]['imageurl']}');
    if(!await file.exists()){
      hasImageReadPermission = false;
    }


    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: Colors.black.withOpacity(0.2),
      ),
      margin: const EdgeInsets.all(7),
      child: InkWell(
        onTap: () => _itemEditor(
            id: _content[index]['id'],
            description: _content[index]['description'],
            image: hasImageReadPermission ?  Image.file(file, fit: BoxFit.cover,) : null),
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
            DatabaseCommunicator.removeItemContent(id: _content[index]['id']).then((value) => _loadListContent());
          }
        },
        child: Container(   //CONTENT
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 17,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: hasImageReadPermission? Image.file(file, fit: BoxFit.cover,) : const Icon(Icons.wallpaper),
                  ),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Flexible(
                flex: 2,
                child: Text(_content[index]['description']),
              )
            ],
          ),
        )
      )
    );
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
  void _itemEditor({int? id, Image? image, String description = ''}) async {
    TextEditingController itemNameController = TextEditingController(text: description);
    bool textEmptyError = false;
    bool nameEditingLocked = true;

    File? newFile;

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
                      onTap: () {_pickImage().then((file) {
                        if(file != null){
                          newFile = file;
                          setState(() => image = Image.file(file, fit: BoxFit.cover,));
                        }
                      });},
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: image ?? Center(child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black.withOpacity(0.1),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                              size: 50,),),)
                        )
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
                          onPressed: () => setState(() {
                          if(nameEditingLocked){
                            itemNameController.selection = TextSelection(baseOffset: 0, extentOffset: itemNameController.value.text.length);
                          } else {
                            itemNameController.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
                          }
                          nameEditingLocked = !nameEditingLocked;
                          }),
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
                        Navigator.pop(context, false);
                      }
                      else {
                        if(id == null){
                          DatabaseCommunicator.addItemContent(
                            parentId: widget.id,
                            name: itemNameController.text,
                            tempImage: newFile
                          ).then((value) => Navigator.pop(context, value));
                        }
                        else {
                          DatabaseCommunicator.updateItemContent(
                            id: id,
                            name: itemNameController.text,
                            tempImage: newFile
                          ).then((value) => Navigator.pop(context, value));
                        }
                      }
                    },
                    child: const Text('SPEICHERN')
                ),
              ],
            );
          },
        );
      }
    ).then((value) {
      if(value){
        _loadListContent();
      }
    });
  }

  Future<File?> _pickImage() async{
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1600,
      maxWidth: 1600,
      imageQuality: 50,
    );

    File? imageFile;
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    return imageFile;
  }


  //EDIT ITEM NAME ->Main purpose: show Details of an Item, let the user edit them and
  //    provide a possibility for adding new items.
  void _editName() async {
    TextEditingController _controller = TextEditingController(text: _item.name);
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.value.text.length);
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

    if(input != _item.name){     //NAME CHANGED? THEN SAVE AND RELOAD NAME&UI
      await locator<DatabaseHandler>().changeItemName(_item.id, _controller.text);
      await _loadItemContent();
      setState(() {});
    }
  }
}
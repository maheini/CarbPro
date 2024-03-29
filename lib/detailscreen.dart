import 'package:carbpro/ui/widgets/emtylistplaceholder.dart';
import 'package:carbpro/ui/widgets/itemcard.dart';
import 'package:carbpro/ui/widgets/itemchild_editor.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'datamodels/item.dart';
import 'datamodels/itemchild.dart';
import 'locator/locator.dart';
import 'handler/databasehandler.dart';
import 'handler/storagehandler.dart';
import 'package:carbpro/generated/l10n.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Item _item = Item(0, '');
  List<ItemChild> _itemChildren = [];

  List<Widget> _generatedContentItems = [];

  @override
  @protected
  @mustCallSuper
  void initState() {
    if (!locator.isRegistered<ImagePicker>()) {
      locator.registerLazySingleton<ImagePicker>(() => ImagePicker());
    }
    super.initState();
    _loadFullContent();
  }

  void _loadFullContent() async {
    await _loadItemContent();
    await _loadItemChildren();
    _generatedContentItems = await _buildList();
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
    var size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 2;
    final double itemHeight = itemWidth + 55;
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editName,
          )
        ],
      ),
      body: _generatedContentItems.isEmpty
          ? EmptyListPlaceholder(
              text: S.of(context).start_with_first_itemchild,
            )
          : GridView.count(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: 2,
              children: _generatedContentItems,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _itemEditor(),
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  //LOAD ALL VALUES OF THIS ITEM AND SET NEW STATE
  Future<List<Widget>> _buildList() async {
    //GENERATE LIST WITH IMAGES AND THEIR DESCRIPTION
    List<Widget> _tempContentList = [];
    for (int x = 0; x < _itemChildren.length; x++) {
      _tempContentList.add(await _createListTile(_itemChildren[x]));
    }
    return _tempContentList;
  }

  //CREATE LIST TILE
  Future<Widget> _createListTile(ItemChild item) async {
    Directory dir =
        await locator<StorageHandler>().getExternalStorageDirectory() ??
            Directory('');

    File file = File('${dir.path}/${item.imagepath}');
    bool fileExists = await locator<StorageHandler>().exists(file);

    return ItemCard(
      onTap: () => _itemEditor(itemChild: item),
      onLongPress: () async {
        bool remove = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).confirm),
              content: Text(S.of(context).warning_confirm_remove),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(S.of(context).cancel.toUpperCase()),
                ),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(S.of(context).remove.toUpperCase())),
              ],
            );
          },
        );

        if (remove) {
          if (await locator<StorageHandler>().exists(file)) {
            await locator<StorageHandler>().deleteFile(file.path);
          }
          await locator<DatabaseHandler>().deleteItemChild(item);
          await _loadItemChildren();
          _generatedContentItems = await _buildList();
          setState(() {});
        }
      },
      title: item.description,
      value: item.value,
      image: fileExists ? file : null,
    );
  }

  // Item editor
  void _itemEditor({ItemChild? itemChild}) async {
    itemChild ??= ItemChild(0, widget.id, '', 0, '');

    await showDialog(
      context: context,
      builder: (BuildContext context) => ItemChildEditor(
        itemChild: itemChild!,
        onCancel: Navigator.of(context).pop,
        onSave: (itemChild, imageHasChanged) async {
          // Is card empty? Then cancel saving...
          if (itemChild.description.isEmpty &&
              itemChild.value == 0 &&
              itemChild.imagepath.isEmpty) {
            Navigator.pop(context);
            return;
          }
          // Save itemChild
          else {
            await _setItemChild(
                itemChild: itemChild, hasImageChanged: imageHasChanged);
          }
          Navigator.pop(context);
          await _loadItemChildren();
          _generatedContentItems = await _buildList();
          setState(() {});
        },
      ),
    );
  }

  /// Updates and/or add ItemChild inside File sytem and database
  /// remember to serve newImagePath if your image isn't inside the default dir.
  ///
  /// returns false if there is any error (file System, no externalStorageDirectory, Database error...)
  Future<bool> _setItemChild(
      {required ItemChild itemChild, bool? hasImageChanged}) async {
    if (hasImageChanged != null && hasImageChanged) {
      Directory? dirPrefix =
          await locator<StorageHandler>().getExternalStorageDirectory();
      if (dirPrefix == null) return false;

      final String filename = path.basename(itemChild.imagepath);

      File copyFile = await locator<StorageHandler>()
          .copyFile(itemChild.imagepath, '${dirPrefix.path}/$filename');
      if (!await locator<StorageHandler>().exists(copyFile)) return false;

      itemChild.imagepath = filename;
    }
    if (itemChild.id == 0) {
      if (await locator<DatabaseHandler>().addItemChild(itemChild) > 0) {
        return true;
      }
    } else {
      if (await locator<DatabaseHandler>().updateItemChild(itemChild) > 0) {
        return true;
      }
    }
    return false;
  }

  //EDIT ITEM NAME ->Main purpose: show Details of an Item, let the user edit them and
  //    provide a possibility for adding new items.
  void _editName() async {
    TextEditingController _controller = TextEditingController(text: _item.name);
    _controller.selection = TextSelection(
        baseOffset: 0, extentOffset: _controller.value.text.length);
    bool textEmptyError = false;
    String? input = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(S.of(context).edit_item),
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
                    child: Text(S.of(context).cancel.toUpperCase()),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(S.of(context).save.toUpperCase()),
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        setState(() => textEmptyError = true);
                      } else {
                        Navigator.pop(context, _controller.text);
                      }
                    },
                  ),
                ],
              );
            },
          );
        });

    if (input != null && input != _item.name) {
      //NAME CHANGED? THEN SAVE AND RELOAD NAME&UI
      await locator<DatabaseHandler>().changeItemName(_item.id, input);
      await _loadItemContent();
      setState(() {});
    }
  }
}

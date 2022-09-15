import 'dart:io';

import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ItemChildEditor extends StatefulWidget {
  const ItemChildEditor({
    required this.itemChild,
    this.onSave,
    this.onCancel,
    Key? key,
  }) : super(key: key);

  final void Function(ItemChild itemChild, bool imageHasChanged)? onSave;
  final VoidCallback? onCancel;
  final ItemChild itemChild;

  @override
  State<ItemChildEditor> createState() => _ItemChildEditorState();
}

class _ItemChildEditorState extends State<ItemChildEditor> {
  File? image;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  File? newImageFile;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void _loadImage() async {
    Directory dir =
        await locator<StorageHandler>().getExternalStorageDirectory() ??
            Directory('');
    File file = File('${dir.path}/${widget.itemChild.imagepath}');
    bool fileExists = await locator<StorageHandler>().exists(file);

    if (fileExists) {
      image = file;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

  }

}


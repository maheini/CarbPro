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
  @override
  Widget build(BuildContext context) {

  }

}


import 'dart:io';

import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

// TODO: Add tests
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
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).description,
              ),
            ),
            InkWell(
              onTap: () {
                _pickImage().then((file) {
                  if (file != null) {
                    setState(() => image = file);
                  }
                });
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black.withOpacity(0.1),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 50,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _valueController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: S.of(context).value,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^[\d./-]+$')),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(S.of(context).cancel.toUpperCase()),
          onPressed: () => widget.onCancel?.call(),
        ),
        TextButton(
          child: Text(S.of(context).save.toUpperCase()),
          onPressed: () {
            ItemChild oldItem = widget.itemChild;

            bool imageHasChanged = false;

            final String name = _nameController.text;
            final double value = double.tryParse(_valueController.text) ?? 0.0;
            String imagepath = oldItem.imagepath;
            // Check if image is not null and is different to widget.itemChild.image
            if (image != null &&
                oldItem.imagepath != path.basename(image!.path)) {
              imageHasChanged = true;
              imagepath = image!.path;
            }

            ItemChild newItem = ItemChild(
              oldItem.id,
              oldItem.parentID,
              name,
              value,
              imagepath,
            );
            widget.onSave?.call(newItem, imageHasChanged);
          },
        ),
      ],
    );
  }

  Future<File?> _pickImage() async {
    XFile? pickedFile = await locator<ImagePicker>().pickImage(
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
}

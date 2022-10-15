import 'dart:io';

import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:carbpro/locator/locator.dart';
import 'package:carbpro/ui/widgets/image_getter.dart';
import 'package:dotted_border/dotted_border.dart';
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

  @override
  void initState() {
    _nameController.text = widget.itemChild.description;
    _valueController.text = widget.itemChild.value.toString();
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
        child: Container(
          //CONTENT
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
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
              const SizedBox(height: 5),
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200],
                    ),
                    child: InkWell(
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
                                    backgroundColor: Colors.grey[350],
                                    child: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 50,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Flexible(child: IntrinsicWidth(child: TextField())),
                      Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.blue[800],
                        child: DottedBorder(
                          borderType: BorderType.Rect,
                          strokeWidth: 2,
                          color: Colors.white.withOpacity(0.7),
                          dashPattern: const [6, 4],
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Row(
                                children: [
                                  IntrinsicWidth(
                                    child: TextField(
                                      controller: _valueController,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: S.of(context).value,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^[\d./-]+$')),
                                      ],
                                      onTap: () => _valueController.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset: _valueController
                                                  .value.text.length),
                                    ),
                                  ),
                                  const Text(
                                    ' g KH',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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

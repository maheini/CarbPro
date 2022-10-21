import 'dart:io';

import 'package:carbpro/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter {
  @visibleForTesting
  ImagePicker imagePicker = ImagePicker();

  Future<File?> getImage(BuildContext context) async {
    File? imageFile;
    int? selection = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(S.of(context).camera),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              onTap: () => Navigator.of(context).pop(0),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(S.of(context).gallery),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              onTap: () => Navigator.of(context).pop(1),
            ),
          ],
        );
      },
    );

    switch (selection) {
      case 0:
        imageFile = await _pickCameraImage();
        break;
      case 1:
        imageFile = await _pickGalleryImage();
        break;
    }
    return imageFile;
  }

  Future<File?> _pickCameraImage() async {
    XFile? pickedFile = await imagePicker.pickImage(
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

  Future<File?> _pickGalleryImage() async {
    XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
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

import 'dart:io';

import 'package:carbpro/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter {
  @visibleForTesting
  ImagePicker imagePicker = ImagePicker();

  Future<File?> getImage(BuildContext context) async {
    File? imageFile;
    await showModalBottomSheet(
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
              onTap: () async {
                imageFile = await _pickCameraImage();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(S.of(context).gallery),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              onTap: () async {
                imageFile = await _pickGalleryImage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

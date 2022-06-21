import 'dart:io';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.title,
    required this.value,
    required this.image,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  final String title;
  final String value;
  final File? image;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Colors.black.withOpacity(0.2),
      ),
      margin: const EdgeInsets.all(7),
      child: Container(
        //CONTENT
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
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.wallpaper),
                ),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Flexible(
              flex: 2,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}

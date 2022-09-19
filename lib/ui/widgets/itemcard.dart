import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
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
  final double value;
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
      child: InkWell(
        onTap: () => onTap?.call(),
        onLongPress: () => onLongPress?.call(),
        child: Container(
          //CONTENT
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Column(
                    children: [
                      ClipRRect(
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
                      const SizedBox(height: 20),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              child: Text(
                                value.toStringAsFixed(
                                        value.truncateToDouble() == value
                                            ? 0
                                            : 1) +
                                    ' g KH',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
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
    );
  }
}

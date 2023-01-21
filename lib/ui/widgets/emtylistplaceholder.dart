import 'package:flutter/material.dart';

class EmptyListPlaceholder extends StatelessWidget {
  const EmptyListPlaceholder({required this.text, this.title, Key? key})
      : super(key: key);

  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title == null
              ? const SizedBox()
              : Text(
                  title ?? '',
                  style: const TextStyle(fontSize: 35),
                ),
          Text(
            text,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/arrow_white.png'
                : 'assets/arrow_black.png',
            fit: BoxFit.cover,
            width: 100,
          ),
        ],
      ),
    );
  }
}

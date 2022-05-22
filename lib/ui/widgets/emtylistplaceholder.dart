import 'package:flutter/material.dart';

// TODO: Test everything
class EmptyListPlaceholder extends StatelessWidget {
  const EmptyListPlaceholder({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

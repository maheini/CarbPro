import 'package:carbpro/generated/l10n.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.about),
        centerTitle: true,
      ),
      body: const Text('about carbpro'),
    );
  }
}

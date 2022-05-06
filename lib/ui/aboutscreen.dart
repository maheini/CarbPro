import 'package:carbpro/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.about),
        centerTitle: true,
      ),

  Widget _buildAppInfo() {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${S.current.version}: $_version'),
          const SizedBox(width: 10),
          Text('${S.current.build}: $_buildNumber'),
        ],
      ),
    );
  }

  Widget _buildAppDescription() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      padding: const EdgeInsets.all(20),
      child: Text(
        S.current.app_description,
        style: const TextStyle(
          fontSize: 17,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

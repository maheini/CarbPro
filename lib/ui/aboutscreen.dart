import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();
  late PackageInfo _packageInfo;
  String _version = '--';
  String _buildNumber = '--';

  void _getPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _version = _packageInfo.version;
    _buildNumber = _packageInfo.buildNumber;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.about),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/adaptive_icon.png',
                fit: BoxFit.cover,
                width: 350,
              ),
            ),
            // const SizedBox(height: 10),
            const Text(
              'CarbPro',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            _buildAppInfo(),
            _buildAppDescription(),
            _buildDeveloperInfo(),
          ],
        ),
      ),
    );
  }

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
        // textAlign: TextAlign.justify,
      ),
    );
  }

  @visibleForTesting
  PlatformWrapper platformWrapper = PlatformWrapper();

  Widget _buildDeveloperInfo() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      padding: const EdgeInsets.all(20),
      child: Text(
        S.current.app_developer_info,
        style: const TextStyle(
          fontSize: 17,
        ),
        // textAlign: TextAlign.justify,
      ),
    );
  }

        textAlign: TextAlign.justify,
      ),
    );
  }
}

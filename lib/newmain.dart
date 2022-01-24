import 'package:flutter/material.dart';
import 'detailscreen.dart';

void main() =>runApp(MaterialApp(
    onGenerateRoute: (settings) {
      if (settings.name == '/details') {
        return MaterialPageRoute(builder: (_) => DetailScreen(id: settings.arguments as int)); // Pass it to BarPage.
      }
      else if (settings.name == '/'){
        return MaterialPageRoute(builder: (_) => const CarbPro());
      }
      return null; // Let `onUnknownRoute` handle this behavior.
    },
    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
    title: 'CarbPro',
  )
);

class CarbPro extends StatefulWidget {
  const CarbPro({Key? key}) : super(key: key);

  @override
  _CarbProState createState() => _CarbProState();
}

class _CarbProState extends State<CarbPro> {
  @visibleForTesting
  bool databaseIsOpen = false;
  @visibleForTesting
  bool hasFilePermission = false;
  void prepareApp() async {
    hasFilePermission = await requestFilePermission();
    if(hasFilePermission){
      databaseIsOpen = await openDatabase();
    }
  }

  Future<bool> requestFilePermission() async {
    return false;
  }

  Future<bool> openDatabase() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

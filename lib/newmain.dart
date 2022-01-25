import 'package:flutter/material.dart';
import 'detailscreen.dart';
import 'homescreen.dart';

void main() {
  runApp(
    const CarbPro()
  );
}
class CarbPro extends StatelessWidget {
  const CarbPro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          return MaterialPageRoute(builder: (_) => DetailScreen(id: settings.arguments as int)); // Pass it to BarPage.
        }
        else if (settings.name == '/'){
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
        return null; // Let `onUnknownRoute` handle this behavior.
      },
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      title: 'CarbPro',
    );
  }
}
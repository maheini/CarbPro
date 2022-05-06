import 'package:carbpro/locator/locator.dart';
import 'package:carbpro/ui/aboutscreen.dart';
import 'package:flutter/material.dart';
import 'detailscreen.dart';
import 'package:carbpro/ui/homescreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:carbpro/generated/l10n.dart';

void main() {
  setupLocator();
  runApp(const CarbPro());
}

class CarbPro extends StatelessWidget {
  const CarbPro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          return MaterialPageRoute(
              builder: (_) => DetailScreen(id: settings.arguments as int));
        } else if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        } else if (settings.name == '/about') {
          return MaterialPageRoute(builder: (_) => const AboutScreen());
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

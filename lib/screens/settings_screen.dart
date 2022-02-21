import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../screens/calenders_screen.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('language')
      ),
      body: Column(
        children: [
          ListTile(
            title: const LocaleText('language'),
            onTap: () {
              Navigator.of(context).pushNamed(LanguageScreen.routeName);
            },
          ),
          ListTile(
            title: const LocaleText('calenderType'),
            onTap: () {
              Navigator.of(context).pushNamed(CalendersScreen.routeName);
            },
          ),
        ],
      )
    );
  }
}

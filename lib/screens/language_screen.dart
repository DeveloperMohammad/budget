import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  static const routeName = '/language';

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('language'),
      ),
      body: Column(children: [
        buildListTile('English', 'en'),
        buildListTile('دری', 'fa'),
      ]),
    );
  }

  Widget buildListTile(String language, String languageCode) {
    return ListTile(
        title: Text(language),
        onTap: () {
          Locales.change(context, languageCode);
        }
    );
  }

}

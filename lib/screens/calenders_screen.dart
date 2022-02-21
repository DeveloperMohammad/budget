import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hive/hive.dart';

class CalendersScreen extends StatelessWidget {

  static const routeName = '/calenders';

  const CalendersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('calenderType'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const LocaleText('solar'),
            onTap: () async {
              Hive.box('extras').put('calender', 'solar');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const LocaleText('gregorian'),
            onTap: () async {
              Hive.box('extras').put('calender', 'gregorian');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

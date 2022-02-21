import 'package:flutter/material.dart';

import 'package:flutter_locales/flutter_locales.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({Key? key}) : super(key: key);

  static const routeName = '/debt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: LocaleText(
          'debtScreen',
          style: TextStyle(fontSize: 45),
        ),
      ),
    );
  }
}

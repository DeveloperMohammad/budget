import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:hive/hive.dart';

import '/screens/home_screen.dart';
import '/screens/debt_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/language_screen.dart';
import '../screens/calenders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(path.path);
  await Hive.openBox('extras');
  await Locales.init(['en', 'fa', 'zh', 'ar', 'es', 'hi']);
  if(Hive.box('extras').isEmpty) {
    Hive.box('extras').put('budget', 0);
    Hive.box('extras').put('totalIncome', 0);
    Hive.box('extras').put('totalExpense', 0);
    Hive.box('extras').put('calender', 'gregorain');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        routes: {
          DebtScreen.routeName: (context) => const DebtScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          LanguageScreen.routeName: (context) => const LanguageScreen(),
          CalendersScreen.routeName: (context) => const CalendersScreen(),
        },
        debugShowCheckedModeBanner: false,
        home: const BottomNavigationBarScreen(),
      ),
    );
  }
}

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  List<Widget> pages = [
    const HomeScreen(),
    const DebtScreen(),
    const SettingsScreen()
  ];
  List<BottomNavigationBarItem> items = [];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home, size: 25), label: Locales.string(context, 'home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.money, size: 25), label: Locales.string(context, 'debt')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings, size: 25), label: Locales.string(context, 'settings'))
        ],
        onTap: (index) {
          setState(() => this.index = index);
        },
      ),
    );
  }
}

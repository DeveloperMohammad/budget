import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '/models/expense.dart';
import '/widgets/expense_list_tile.dart';
import '../database/budget_database.dart';
import '/screens/add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home_page';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum SlidableAction {
  edit,
  delete,
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFabVisible = true;
  bool isLoading = false;

  String? calenderType;

  late Box extrasBox;
  late Box calenderBox;

  List<List<Expense>>? _expenseList;

  Jalali j = DateTime.now().toJalali();
  Gregorian g = DateTime.now().toGregorian();

  @override
  void initState() {
    extrasBox = Hive.box('extras');
    // Hive.box('extras').clear();
    calenderType = Hive.box('extras').get('calender');
    super.initState();
    _updateExpenseList();
  }

  String format(Date d) {
    final f = d.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}  ${f.wN}';
  }

  _updateExpenseList() async {
    setState(() => isLoading = true);
    _expenseList = await BudgetDatabase.instance.getExpenseList();
    setState(() => isLoading = false);
  }

  int _totalExpense = 0;
  int _totalIncome = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('extras').listenable(),
        builder: (context, Box extras, child) {
          return Scaffold(
            appBar: AppBar(
              title: const LocaleText('appName'),
              elevation: 0,
              centerTitle: true,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.15,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const LocaleText(
                                      'appName',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      '${extras.get('budget') ?? 0}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const LocaleText(
                                      'income',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      '${extras.get('totalIncome') ?? 0}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const LocaleText(
                                      'expense',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      '${extras.get('totalExpense') ?? 0}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.forward) {
                    if (!isFabVisible) setState(() => isFabVisible = true);
                  } else if (notification.direction ==
                      ScrollDirection.reverse) {
                    if (isFabVisible) setState(() => isFabVisible = false);
                  }
                  return true;
                },
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Scrollbar(
                        thickness: 5,
                        interactive: true,
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox();
                          },
                          itemCount: _expenseList!.length,
                          itemBuilder: (context, index) {
                            _totalIncome = 0;
                            _totalExpense = 0;
                            for (var listItem in _expenseList![index]) {
                              if (listItem.isIncome == 1) {
                                _totalIncome += int.parse(listItem.price);
                              } else if (listItem.isIncome == 0) {
                                _totalExpense += int.parse(listItem.price);
                              }
                            }
                            return Column(children: [
                              const SizedBox(height: 10),
                              Text(calenderType == 'solar'
                                  ? format(
                                      _expenseList![index][0].date.toJalali())
                                  : format(_expenseList![index][0]
                                      .date
                                      .toGregorian())),
                              Row(
                                children: [
                                  const SizedBox(width: 20),
                                  _totalExpense != 0
                                      ? Row(
                                          children: [
                                            const LocaleText(
                                              'expense',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(': $_totalExpense')
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                  _totalExpense > 0
                                      ? const SizedBox(width: 120)
                                      : const SizedBox.shrink(),
                                  _totalIncome != 0
                                      ? Row(
                                          children: [
                                            const LocaleText(
                                              'income',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(': $_totalIncome')
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              Column(
                                children:
                                    _expenseList![index].map((expenseItem) {
                                  return ExpenseListTile(
                                    updateExpenseList: _updateExpenseList,
                                    expense: expenseItem,
                                  );
                                }).toList(),
                              ),
                            ]);
                          },
                        ),
                      ),
              ),
            ),
            floatingActionButton: isFabVisible
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExpenseScreen(
                            updateExpenses: _updateExpenseList,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        });
  }
}

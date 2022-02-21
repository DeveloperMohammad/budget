import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';

import 'package:shamsi_date/shamsi_date.dart';

import '../database/budget_database.dart';
import '/screens/add_expense_screen.dart';
import '/screens/home_screen.dart';
import '/models/expense.dart';

class ExpenseListTile extends StatefulWidget {
  const ExpenseListTile(
      {Key? key, required this.expense, this.updateExpenseList})
      : super(key: key);

  final Expense expense;
  final Function? updateExpenseList;

  @override
  State<ExpenseListTile> createState() => _ExpenseListTileState();
}

class _ExpenseListTileState extends State<ExpenseListTile> {

  String? calenderType;
  late Box extrasBox;
  String? dateTime;

  Jalali j = DateTime.now().toJalali();
  Gregorian g = DateTime.now().toGregorian();

  @override
  void initState() {
    extrasBox = Hive.box('extras');
    calenderType = Hive.box('extras').get('calender');
    super.initState();
    if (calenderType == 'gregorian') {
      g = widget.expense.date.toGregorian();
    } else if (calenderType == 'solar') {
      j = widget.expense.date.toJalali();
    }
  }

  String format(Date d) {
    final f = d.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}  ${f.wN}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15, left: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(),
      ),
      child: Slidable(
        actionPane: const SlidableStrechActionPane(),

        // left side
        actions: [
          IconSlideAction(
            caption: Locales.string(context, 'edit'),
            color: Colors.green[700],
            icon: Icons.edit,
            onTap: () => onDismissed(SlidableAction.edit),
          ),
        ],

        // right side
        secondaryActions: [
          IconSlideAction(
            caption: Locales.string(context, 'delete'),
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => onDismissed(SlidableAction.delete),
          )
        ],

        child: ListTile(
          dense: true,
          leading: Image.asset('assets/icons/${widget.expense.imageUrl}.png'),
          title: Text(
            widget.expense.title,
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.expense.description.isNotEmpty ? true : false,
                child: Text(widget.expense.description),
              ),
              calenderType != null
                  ? Text(calenderType == 'solar' ? format(j) : format(g))
                  : const Text('Calender Type not available',
                      style: TextStyle(color: Colors.red)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.expense.isIncome == 1
                    ? widget.expense.price
                    : '–${widget.expense.price}',
                style: TextStyle(
                    fontSize: 20,
                    color: widget.expense.isIncome == 1
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDismissed(SlidableAction action) async {
    switch (action) {
      case SlidableAction.edit:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddExpenseScreen(
              expense: widget.expense,
              updateExpenses: widget.updateExpenseList,
            ),
          ),
        );
        break;

      case SlidableAction.delete:
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              title: const LocaleText('deleteItem'),
              content: const LocaleText('deleteMessage'),
              contentPadding: const EdgeInsets.only(
                  bottom: 5, top: 15, left: 20, right: 20),
              actions: [
                ElevatedButton(
                  onPressed: () async {

                    int currentTotalExpense = await extrasBox.get('totalExpense');
                    int currentTotalIncome = await extrasBox.get('totalIncome');
                    int currentBudget = await extrasBox.get('budget');
                    final oldMoney = int.parse(widget.expense.price);

                    final isIncome =
                        widget.expense.isIncome == 1 ? true : false;

                    if (isIncome) {
                      currentTotalIncome -= oldMoney;
                      currentBudget -= oldMoney;
                    } else {
                      currentTotalExpense -= oldMoney;
                      currentBudget += oldMoney;
                    }
                    extrasBox.put('totalExpense', currentTotalExpense);
                    extrasBox.put('totalIncome', currentTotalIncome);
                    extrasBox.put('budget', currentBudget);
                    BudgetDatabase.instance.deleteExpense(widget.expense.id!);
                    widget.updateExpenseList!();
                    Navigator.of(context).pop();
                  },
                  child: const LocaleText('yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const LocaleText('no'),
                ),
              ],
            );
          },
        );
        break;
    }
  }
}

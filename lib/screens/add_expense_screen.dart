import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../models/expense.dart';
import '../database/budget_database.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final Function? updateExpenses;

  static const routeName = '/add_expense';

  const AddExpenseScreen({Key? key, this.expense, this.updateExpenses})
      : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

DateFormat _dateFormatter = DateFormat('MMM dd yyyy');

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late Box extrasBox;

  String? calenderType;
  int isIncome = 0;
  String imageUrl = 'other';
  bool isUpdating = false;
  String? title;
  String? description;
  String? price;
  DateTime _date = DateTime.now();
  int tabNumber = 0;

  Jalali _jDate = Jalali.now();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<String> expenseIconNames = [
    'accessory',
    'clothes',
    'cosmetic',
    'drink',
    'electric',
    'entertainment',
    'fitness',
    'food',
    'fruit',
    'gift',
    'grocery',
    'medical',
    'shopping',
    'water',
    'bill',
    'sport',
    'transportation',
    'other'
  ];

  List<String> incomeIconNames = [
    'gift',
    'paycheck',
    'salary',
    'award',
    'grants',
    'sale',
    'rental',
    'refunds',
    'coupon',
    'dividends',
    'investment',
    "fees",
    'other',
  ];

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      dateController.text = _dateFormatter.format(date);
    }
  }

  _handlePersianPicker() async {
    var jDate = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1400,01,01),
      lastDate: Jalali(1402,01,01),
    );
    if (jDate != null && jDate != _jDate) {
      setState(() {
        _jDate = jDate;
      });
      dateController.text = _dateFormatter.format(jDate.toDateTime());
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    extrasBox = Hive.box('extras');
    calenderType = Hive.box('extras').get('calender');
    if (widget.expense != null) {
      // if is updating
      titleController.text = widget.expense!.title;
      priceController.text = widget.expense!.price;
      descriptionController.text = widget.expense!.description;
      dateController.text = _dateFormatter.format(widget.expense!.date);
      isIncome = widget.expense!.isIncome;
      imageUrl = widget.expense!.imageUrl;
      _date = widget.expense!.date;
      Gregorian g = Gregorian(widget.expense!.date.year, widget.expense!.date.month, widget.expense!.date.day);
      _jDate = g.toJalali();
      isUpdating = true;
    } else {
      Future.delayed(Duration.zero).then((_) {
        showModalBottomSheet(
            transitionAnimationController: AnimationController(
                vsync: this, duration: const Duration(milliseconds: 500)),
            context: context,
            builder: (_) {
              return buildTabBar();
            });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) => buildTabBar(),
                            transitionAnimationController: AnimationController(
                                vsync: this,
                                duration: const Duration(milliseconds: 500)));
                      },
                      controller: titleController,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 0),
                          child: Image.asset(
                            'assets/icons/$imageUrl.png',
                            width: 40,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(),
                        hintText:
                            Locales.string(context, 'expenseOrIncomeType'),
                        labelText:
                            Locales.string(context, 'expenseOrIncomeType'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (input) => input!.trim().isEmpty
                          ? Locales.string(context, 'nameError')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(),
                        hintText: Locales.string(context, 'price'),
                        labelText: Locales.string(context, 'price'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (input) => input!.trim().isEmpty
                          ? Locales.string(context, 'priceError')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(),
                        hintText: Locales.string(context, 'description'),
                        labelText: Locales.string(context, 'description'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// This is date form field
                    TextFormField(
                      readOnly: true,
                      onTap: calenderType == 'solar' ? _handlePersianPicker : _handleDatePicker,
                      controller: dateController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        hintText: 'Pick a date',
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 40,
        width: double.infinity,
        color: Colors.blue,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // Add Expense to Total Expense
              int currentTotalExpense = await extrasBox.get('totalExpense');

              // Add Income to Total Income
              int currentTotalIncome = await extrasBox.get('totalIncome');

              // Add Income / Expense to Budget
              int currentBudget = await extrasBox.get('budget');

              // The money from price controller text field
              int newMoney = int.parse(priceController.text);

              Expense expense = Expense(
                title: titleController.text,
                price: priceController.text,
                description: descriptionController.text,
                isIncome: isIncome,
                date: calenderType == 'solar' ? _jDate.toGregorian().toDateTime() : _date,
                imageUrl: imageUrl,
              );

              if (isUpdating) {
                expense.id = widget.expense!.id;
                // get specific item's value to update
                int itemValue = int.parse(widget.expense!.price);
                bool wasExpense = widget.expense!.isIncome == 0;

                if (isIncome == 1) {
                  // 1 means it is income
                  if (wasExpense) {
                    // if it was previously an expense

                    // update total income and total expense if it was previously an expense
                    currentTotalExpense -= itemValue;
                    currentTotalIncome += newMoney;

                    // update the budget if it was previously an expense
                    int newBudget = newMoney + itemValue;

                    extrasBox.put('budget', newBudget + currentBudget);
                    extrasBox.put('totalIncome', currentTotalIncome);
                    extrasBox.put('totalExpense', currentTotalExpense);
                  } else {
                    // if it was an income already

                    // update total expense and total income if it was an income already
                    currentTotalIncome -= itemValue;
                    currentTotalIncome += newMoney;

                    // update the budget if it was an income already
                    currentBudget -= itemValue;
                    currentBudget += newMoney;

                    extrasBox.put('budget', currentBudget);
                    extrasBox.put('totalIncome', currentTotalIncome);
                  }
                } else {
                  // IF IS EXPENSE
                  if (wasExpense == false) {
                    // If it was income before

                    // update total income and total expense if it was income before
                    currentTotalIncome -= itemValue;
                    currentTotalExpense += newMoney;

                    // update budget if it was income before
                    int result = newMoney + itemValue;
                    int newBudget = currentBudget - result;

                    extrasBox.put('totalIncome', currentTotalIncome);
                    extrasBox.put('totalExpense', currentTotalExpense);
                    extrasBox.put('budget', newBudget);
                  } else {
                    // update total expense if it was an expense already
                    currentTotalExpense -= itemValue;
                    currentTotalExpense += newMoney;

                    // update the budget if it was an expense already
                    currentBudget += itemValue;
                    int newBudget = currentBudget - newMoney;

                    extrasBox.put('totalExpense', currentTotalExpense);
                    extrasBox.put('budget', newBudget);
                  }
                }
                // await expenseBox.putAt(widget.index, expense);
                BudgetDatabase.instance.updateExpense(expense);
              } else {
                // WE ARE ADDING NEW EXPENSE / INCOME
                if (isIncome == 1) {
                  // Add income to total income
                  int newTotalIncome = currentTotalIncome + newMoney;
                  await extrasBox.put('totalIncome', newTotalIncome);

                  // Add income to budget
                  int newBudget = newMoney + currentBudget;
                  await extrasBox.put('budget', newBudget);
                } else {
                  // Add expense to total expense
                  int newTotalExpense = currentTotalExpense + newMoney;
                  await extrasBox.put('totalExpense', newTotalExpense);

                  // Add expense to budget
                  int newBudget = currentBudget - newMoney;
                  await extrasBox.put('budget', newBudget);
                }
                // Add the new expense to expense box
                BudgetDatabase.instance.insertExpense(expense);
              }
              widget.updateExpenses!();
              Future.delayed(Duration.zero).then((_) {
                Navigator.pop(context);
              });
            }
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
          ),
          child: const LocaleText('addAmount'),
        ),
      ),
    );
  }

  Widget buildTabBar() {
    List<Map<String, dynamic>> localeExpenseIconNames = [
      {'name': Locales.string(context, 'accessory_label'), 'isSelected': false},
      {'name': Locales.string(context, 'clothes_label'), 'isSelected': false},
      {'name': Locales.string(context, 'cosmetic_label'), 'isSelected': false},
      {'name': Locales.string(context, 'drink_label'), 'isSelected': false},
      {'name': Locales.string(context, 'electric_label'), 'isSelected': false},
      {
        'name': Locales.string(context, 'entertainment_label'),
        'isSelected': false
      },
      {'name': Locales.string(context, 'fitness_label'), 'isSelected': false},
      {'name': Locales.string(context, 'food_label'), 'isSelected': false},
      {'name': Locales.string(context, 'fruit_label'), 'isSelected': false},
      {'name': Locales.string(context, 'gift_label'), 'isSelected': false},
      {'name': Locales.string(context, 'grocery_label'), 'isSelected': false},
      {'name': Locales.string(context, 'medical_label'), 'isSelected': false},
      {'name': Locales.string(context, 'shopping_label'), 'isSelected': false},
      {'name': Locales.string(context, 'water_label'), 'isSelected': false},
      {'name': Locales.string(context, 'bill_label'), 'isSelected': false},
      {'name': Locales.string(context, 'sport_label'), 'isSelected': false},
      {
        'name': Locales.string(context, 'transportation_label'),
        'isSelected': false
      },
      {'name': Locales.string(context, 'others_label'), 'isSelected': false},
    ];

    List<Map<String, dynamic>> localeIncomeIconNames = [
      {'name': Locales.string(context, 'gift_label'), 'isSelected': false},
      {'name': Locales.string(context, 'paycheck_label'), 'isSelected': false},
      {'name': Locales.string(context, 'salary_label'), 'isSelected': false},
      {'name': Locales.string(context, 'award_label'), 'isSelected': false},
      {'name': Locales.string(context, 'grants_label'), 'isSelected': false},
      {'name': Locales.string(context, 'sale_label'), 'isSelected': false},
      {'name': Locales.string(context, 'rental_label'), 'isSelected': false},
      {'name': Locales.string(context, 'refunds_label'), 'isSelected': false},
      {'name': Locales.string(context, 'coupons_label'), 'isSelected': false},
      {'name': Locales.string(context, 'dividends_label'), 'isSelected': false},
      {
        'name': Locales.string(context, 'investment_label'),
        'isSelected': false
      },
      {'name': Locales.string(context, 'fees'), 'isSelected': false},
      {'name': Locales.string(context, 'others_label'), 'isSelected': false},
    ];

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: DefaultTabController(
        initialIndex: isIncome,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 35,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  overlayColor: MaterialStateProperty.all(Colors.black54),
                  onTap: (tapIndex) {
                    if (tapIndex == 0) {
                      isIncome = 0;
                    } else if (tapIndex == 1) {
                      isIncome = 1;
                    }
                  },
                  tabs: const [
                    Tab(
                      height: 30,
                      child: LocaleText('expense'),
                    ),
                    Tab(
                      height: 30,
                      child: LocaleText('income'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: expenseIconNames.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        titleController.text =
                            localeExpenseIconNames[index]['name'];
                        imageUrl = expenseIconNames[index];
                        Navigator.of(context).pop();
                      });
                    },
                    child: IconGrid(
                      iconName: expenseIconNames[index],
                      iconLabel: localeExpenseIconNames[index]['name'],
                      selectedIconName: widget.expense?.imageUrl ?? '',
                    ),
                  );
                },
              ),

              // Income list
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: incomeIconNames.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        titleController.text =
                            localeIncomeIconNames[index]['name'];
                        imageUrl = incomeIconNames[index];
                        Navigator.of(context).pop();
                      });
                    },
                    child: IconGrid(
                      iconName: incomeIconNames[index],
                      iconLabel: localeIncomeIconNames[index]['name'],
                      selectedIconName: widget.expense?.imageUrl ?? '',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconGrid extends StatelessWidget {
  const IconGrid({
    Key? key,
    required this.iconName,
    required this.iconLabel,
    required this.selectedIconName,
  }) : super(key: key);
  final String iconName;
  final String iconLabel;
  final String selectedIconName;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      header: iconName == selectedIconName
          ? const Icon(Icons.verified, color: Colors.blue, size: 30)
          : const SizedBox.shrink(),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/$iconName.png',
            width: 40,
          ),
          const SizedBox(height: 5),
          Expanded(child: Text(iconLabel, textAlign: TextAlign.center))
        ],
      ),
    );
  }
}

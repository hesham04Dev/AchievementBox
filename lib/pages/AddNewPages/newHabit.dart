import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:provider/provider.dart';

import '../../db/db.dart';
import '../../models/AutoDirectionTextFormField.dart';
import '../../models/mySwitchTile.dart';
import '../../rootProvider/habitProvider.dart';
import 'newCategory.dart';
import 'widget/CategoryDropDown.dart';
import 'widget/NumericField.dart';
import 'widget/icon.dart';
import 'widget/select with name.dart';

class NewHabitPage extends StatefulWidget {
  NewHabitPage({super.key, this.title = ""});
  List<Widget>? actions;
  String title;
  static const int gearIconId = 39;

  @override
  State<NewHabitPage> createState() => NewHabitPageState();
}

class NewHabitPageState extends State<NewHabitPage> {
  late final TextEditingController name;
  late final TextEditingController coins;
  late final TextEditingController time;
  late final TextEditingController category;
  late final GlobalKey<FormState> formKey;
  late final Select priority;
  late final Select hardness;
  late final MySwitchTile isBad;
  late SelectIcon selectIcon;
  List<Widget>? children;
  late final CategoryDropDown categoryDropDown;

  void save(BuildContext context) {
    if (formKey.currentState!.validate()) {
      db.sql.habits.add(
          name: name.text,
          categoryId: categoryDropDown.selectedId,
          isBad: isBad.value,
          price: int.parse(coins.text),
          iconId: selectIcon.selectedIconId ?? NewHabitPage.gearIconId,
          priority: priority.selected,
          hardness: hardness.selected,
          timeInMinutes: int.parse(time.text));

      context.read<HabitProvider>().newHabit();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    name = TextEditingController();
    coins = TextEditingController();
    time = TextEditingController();
    category = TextEditingController();
    formKey = GlobalKey<FormState>();
    priority = Select(
      label: tr("priority"),
      length: 5,
    );
    hardness = Select(
      label: tr("hardness"),
      length: 5,
    );

    isBad = MySwitchTile(title: "${tr("isBad")}?");
    categoryDropDown = CategoryDropDown(
      controller: category,
    );
    selectIcon = SelectIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ==""?tr("newHabit"):widget.title),
        actions: widget.actions,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
                key: formKey,
                child: Column(
                  children: [
                    selectIcon,
                    const SizedBox(
                      height: 10,
                    ),
                    AutoDirectionTextFormField(
                        controller: name,
                        errMessage: tr("pleaseEnterName"),
                        hintText: tr("name")),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        categoryDropDown,
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => NewCategoryPage()));
                          },
                          child: Text(tr("newCategory")),
                        )
                      ],
                    ),
                    priority,
                    hardness,
                    NumericField(
                      controller: coins,
                      hintText: tr("coins"),

                      maxValue: 10000,
                    ),
                    NumericField(
                      controller: time,
                      hintText: tr("timeInMinute"),
                      maxValue: 24 * 60,
                    ),
                    ...?children,
                    const SizedBox(
                      height: 10,
                    ),
                    isBad,
                    TextButton(
                      onPressed: () {
                        save(context);
                      },
                      child:  Text(tr("save")),
                      //color: Theme.of(context).primaryColor.withOpacity(0.5),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    time.dispose();
    coins.dispose();
    name.dispose();
    super.dispose();
  }
}

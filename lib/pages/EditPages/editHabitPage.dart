
import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:provider/provider.dart';

import '../../db/db.dart';
import '../../models/habit.dart';
import '../../output/generated/icon_names.dart';
import '../../rootProvider/habitProvider.dart';
import '../../models/PrimaryContainer.dart';
import '../../models/imageIcon.dart';
import '/models/ActivityCharts.dart';
import '/models/log.dart';

import '../AddNewPages/newHabit.dart';
import '../AddNewPages/widget/icon.dart';
import '../ArchivePage/archivePage.dart';

class EditHabitsPage extends NewHabitPage {
  final Habit habit;

  EditHabitsPage({super.key, required this.habit, super.title = ""});

  @override
  State<NewHabitPage> createState() => _EditHabitPageState(habit: habit);
}

class _EditHabitPageState extends NewHabitPageState {
  final Habit habit;
  _EditHabitPageState({required this.habit});
  @override
  void initState() {
    super.initState();
    super.name.text = habit.name;
    super.coins.text = "${habit.price}";
    super.category.text =
        "${db.sql.categories.getById(habit.categoryId)['Name']}";
    super.categoryDropDown.selectedId = habit.categoryId;
    super.time.text = "${habit.timeInMinutes}";
    super.hardness.selected = habit.hardness;
    super.priority.selected = habit.priority;
    super.isBad.value = habit.isBadHabit;

    super.selectIcon = SelectIcon(
      selectedIconName: iconNames[habit.iconId],
    );

    super.selectIcon.selectedIconId = habit.iconId;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.title==""){
      widget.title = tr("editHabit");
    }
    List<Widget> actions = [];
    if (habit.isArchived) {
      actions = [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                db.sql.habits.delete(id: habit.id);
                context.read<HabitProvider>().habitUpdated();
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivePage(),
                    ));
              },
              icon: const Icon(Icons.delete)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                db.sql.habits.restore(id: habit.id);
                context.read<HabitProvider>().habitUpdated();
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivePage(),
                    ));
              },
              icon: const Icon(Icons.settings_backup_restore_rounded)),
        )
      ];
    } else {
      actions = [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                db.sql.habits.archive(id: habit.id);
                context.read<HabitProvider>().habitUpdated();
                Navigator.pop(context);
              },
              icon: IconImage(iconName: "box-archive.png")),
        )
      ];
    }
    widget.actions = actions;
    super.children = [
      PrimaryContainer(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                if (habit.totalTimes > 0) {
                  habit.undo();
                }
                setState(() {});
              },
              child: const Text("-")),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(habit.totalTimes.toString()),
          ),
          TextButton(
              onPressed: () {
                habit.clicked();
                setState(() {});
              },
              child: const Text("+"))
        ],
      )),   
      
      PrimaryContainer(
        padding: 15,
        child: ActivityChart(
          logProvider: LogHabit(), 
          itemId: habit.id,
        ),
      ),
    ];
    return super.build(context);
  }

  @override
  void save(BuildContext context) {
    if (super.formKey.currentState!.validate()) {
      Habit h = Habit(
        id: habit.id,
        name: super.name.text,
        categoryId: super.categoryDropDown.selectedId,
        isBadHabit: super.isBad.value,
        price: int.parse(super.coins.text),
        iconId: selectIcon.selectedIconId ?? NewHabitPage.gearIconId,
        priority: super.priority.selected,
        hardness: super.hardness.selected,
        timeInMinutes: int.parse(super.time.text),
        totalTimes: habit.totalTimes,
        context: context,
        isArchived: false,
      );
      db.sql.habits.update(h);
      context.read<HabitProvider>().habitUpdated();
      Navigator.pop(context);
    }
  }
}

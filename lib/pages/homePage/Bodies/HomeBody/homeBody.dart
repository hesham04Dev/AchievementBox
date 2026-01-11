import 'dart:math';

import 'package:achievement_box/fn/random_item_from_array.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localization_lite/translate.dart';

import '../../../../config/const.dart';
import '../../../../db/db.dart';
import '../../../../models/PrimaryContainer.dart';
import '../../../../models/habit.dart';
import '../../../../models/my_grid_view.dart';
import '../../../../models/topBar.dart';
import '../../../../rootProvider/habitProvider.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    var habits = context.watch<HabitProvider>().Habits;
    return Column(
      children: [
        const TopBar(canLevelChange: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FittedBox(
            child: Text(tr(getRandom(somethingChangedEveryTime))),
          ),
        ),
        Expanded(
          child: PrimaryContainer(
            opacity: 0.1,
            child: db.sql.settings.isListView()
                ? ListView.builder(
                    itemBuilder: (child, index) =>
                        Habit.habitBuilder(context, habits[index]),
                    itemCount: habits.length,
                    shrinkWrap: false,
                  )
                : MyGridView(
                    itemBuilder: (context, index) =>
                        Habit.habitBuilder(context, habits[index]),
                    itemCount: habits.length,
                  ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../db/db.dart';
import '../../models/habitGiftTabPage.dart';
import '../../pages/logPage/models/log.dart';
import '../../pages/logPage/widgets/log_container.dart';
class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // sqlite.ResultSet logHabitDates = db.sql.habits.getDatesOfLog();
    // sqlite.ResultSet logGiftDates = db.sql.gifts.getDatesOfLog();
    return HabitGiftTabPage(
        title: tr("log"),
        tabBarView: TabBarView(
          children: [
            LogContainer(/*dates: logHabitDates,*/ log: LogHabit()),
            LogContainer(/*dates: logGiftDates,*/ log: LogGift())
          ],
        ));
  }
}

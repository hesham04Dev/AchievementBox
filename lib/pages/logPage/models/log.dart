import "package:localization_lite/translate.dart";


import '../../../db/db.dart';

abstract class Log {
  final String name;
  Log(this.name);
  getLogsPerDate(String date);
  getLogsByMonth(String yearMonth);
  getFirstLogDate();
}

class LogHabit extends Log {
  LogHabit() : super(tr("habits"));
  @override
  getLogsPerDate(String date) {
    return db.sql.habits.getLogByDate(date);
  }
  @override
  getLogsByMonth(String yearMonth){
     return db.sql.habits.getLogsByMonth(yearMonth);
  }
  @override
  getFirstLogDate(){
    return db.sql.habits.getFirstLogDate();
  }
}

class LogGift extends Log {
  LogGift() : super(tr("gifts"));
  @override
  getLogsPerDate(String date) {
    return db.sql.gifts.getLogByDate(date);
  }
  @override
  getLogsByMonth(String yearMonth){
     return db.sql.gifts.getLogsByMonth(yearMonth);
  }
  @override
  getFirstLogDate(){
    return db.sql.gifts.getFirstLogDate();
  }
}

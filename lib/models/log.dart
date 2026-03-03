import "package:localization_lite/translate.dart";


import '../../../db/db.dart';

abstract class Log {
  final String name;
  Log(this.name);
  getLogsPerDate(String date);
  getLogsByMonth(String yearMonth);
  getLogByYear(String year, int logedId);
  getLogByMonth(String yearMonth, int logedId);
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
  @override
   getLogByYear(String year, int logedId){
    return db.sql.habits.getLogByYear(year, logedId);
   }
  @override
  getLogByMonth(String yearMonth, int logedId){
    return db.sql.habits.getLogByMonth(yearMonth, logedId);
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

  @override
   getLogByYear(String year, int logedId){
    return db.sql.gifts.getLogByYear(year, logedId);
   }
  @override
  getLogByMonth(String yearMonth, int logedId){
    return db.sql.gifts.getLogByMonth(yearMonth, logedId);
  }
}

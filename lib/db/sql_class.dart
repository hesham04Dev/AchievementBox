import 'package:achievement_box/config/const.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/Category.dart';
import '../models/gift.dart';
import '../models/habit.dart';

final DateTime now = DateTime.now();
final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

class Sql {
  late final Database _db;

  Sql(this._db) {
    habits = HabitFn(_db);
    gifts = GiftFn(_db);
    categories = CategoryFn(_db);
    settings = SettingFn(_db);
  }

  late HabitFn habits;
  late GiftFn gifts;
  late CategoryFn categories;
  late SettingFn settings;
}

class HabitFn {
  final Database _db;

  HabitFn(this._db);

  ResultSet get() {
    /*ResultSet resultSet = _db.select(
      "SELECT habit.*, count FROM habit inner join (select HabitId,count form logHabit where DateOnly = $formattedDate)   ;");*/
    ResultSet resultSet = _db.select('''
  SELECT habit.*, logHabit.count AS count
FROM habit
LEFT JOIN (
    SELECT HabitId, count
    FROM logHabit
    WHERE DateOnly = '$formattedDate'
) AS logHabit ON habit.Id = logHabit.HabitId
WHERE IsArchived =0;
  ''');
    return resultSet;
  }

  ResultSet getArchived() {
    ResultSet resultSet = _db.select('''
  SELECT * FROM habit WHERE IsArchived = 1;
  ''');
    return resultSet;
  }

  ResultSet getTop() {
    ResultSet x = _db.select('''
SELECT h.Name , Sum(lh.Count) as Total
FROM habit h
INNER JOIN logHabit lh ON h.Id = lh.HabitId
GROUP BY h.Id
ORDER BY  Sum(lh.Count) DESC
LIMIT 1;
  ''');
    return x;
  }

  ResultSet getTopDay() {
    ResultSet x = _db.select('''
SELECT lh.DateOnly , SUM(lh.Count * lh.Price) AS Total
FROM  logHabit AS lh 
GROUP BY lh.DateOnly
ORDER BY SUM(lh.Count * lh.Price) DESC
LIMIT 1;
  ''');

    return x;
  }

  ResultSet getWeeklyData() {
    /*var x = _db.select('''
SELECT lh.DateOnly, SUM(lh.Count * h.Price) AS Total
FROM habit AS h
INNER JOIN logHabit AS lh ON h.Id = lh.HabitId
WHERE h.IsBad = False
GROUP BY lh.DateOnly
ORDER BY lh.DateOnly desc
LIMIT 7;
  ''');*/
    // var x = _db.select('''
    // SELECT lh.DateOnly, 
    // SUM(CASE WHEN h.IsBad = False THEN lh.Count * h.Price ELSE 0 END) - 
    // SUM(CASE WHEN h.IsBad = True THEN lh.Count * h.Price ELSE 0 END) AS Total
    // FROM habit AS h INNER JOIN logHabit AS lh ON h.Id = lh.HabitId
    // GROUP BY lh.DateOnly
    // ORDER BY lh.DateOnly DESC
    // LIMIT 7;''');
    var x = _db.select('''
    SELECT lh.DateOnly,  SUM(lh.Count * lh.Price) AS Total
    FROM  logHabit AS lh 
    GROUP BY lh.DateOnly
    ORDER BY lh.DateOnly DESC
    LIMIT 7;''');
    return x;
  }

  ResultSet getLogByDate(String date) {
    return _db.select(
        "select  logHabit.*,habit.Name from logHabit inner join habit on logHabit.HabitId = habit.Id where DateOnly = '$date'");
  }

  ResultSet getDatesOfLog() {
    return _db.select(
        "select distinct DateOnly from logHabit order by DateOnly desc ");
  }

  // void addToLog(int id) {
  //   // _db.execute('''
  //   //   insert into logHabit values('$formattedDate',$id,1)
  //   //   ''');
  // }

  void addToLog(int id) {
  _db.execute('''
    INSERT INTO logHabit (DateOnly, HabitId, Count, Price)
    VALUES (
      '$formattedDate',
      $id,
      1,
      (
        SELECT CASE 
                 WHEN IsBad = 1 THEN -1 * Price 
                 ELSE Price 
               END
        FROM habit
        WHERE Id = $id
      )
    );
  ''');
}

  void updateLog({required int id, required int count}) {
    _db.execute('''
      update  logHabit set
      count = $count
      where DateOnly = '$formattedDate'
      and HabitId =$id
      ''');
  }

  void deleteFromLog(int id) {
    _db.execute('''
      delete from logHabit where HabitId = $id and DateOnly = '$formattedDate'
      ''');
  }

  void update(Habit habit) {
    _db.execute('''UPDATE habit set Name = '${habit.name}',
  Category = ${habit.categoryId},
  IsBad = ${habit.isBadHabit},
  IconId = ${habit.iconId},
  Priority = ${habit.priority},
  Hardness = ${habit.hardness},
  Price = ${habit.price},
  TimeInMinutes = ${habit.timeInMinutes}
  WHERE Id = ${habit.id} ''');
  }

  void delete({required int id}) {
    _db.execute("delete from logHabit where HabitId = ?", [id]);
    _db.execute("delete from habit where Id = $id");
  }

  void archive({required int id}) {
    _db.execute("update habit set IsArchived = 1  where Id = ?", [id]);
  }

  void restore({required int id}) {
    _db.execute("update habit set IsArchived = 0  where Id = ?", [id]);
  }

  void add(
      {required String name,
      required int categoryId,
      required bool isBad,
      required int price,
      required int iconId,
      required int priority,
      required int hardness,
      required int timeInMinutes}) {
    _db.execute(
        "INSERT INTO habit('Name','Category','IsBad','Price','IconId','Priority','Hardness','TimeInMinutes') VALUES ('$name',$categoryId,$isBad,$price,$iconId,$priority,$hardness,$timeInMinutes)");
  }
}

class GiftFn {
  final _db;

  GiftFn(this._db);

  ResultSet get() {
    ResultSet resultSet = _db.select("SELECT * FROM gift where IsArchived =0;");
    return resultSet;
  }

  ResultSet getArchived() {
    ResultSet resultSet = _db.select("SELECT * FROM gift where IsArchived =1;");
    return resultSet;
  }

  ResultSet getMostUsed(int limit) {
    ResultSet resultSet = _db.select(
        '''SELECT * FROM gift  WHERE NoOfUsed > 0 and IsArchived = 0 ORDER BY NoOfUsed DESC  LIMIT $limit;''');
    return resultSet;
  }

  ResultSet getTop() {
    var x = _db.select('''
  SELECT Name , NoOfUsed as Total
FROM gift
ORDER BY NoOfUsed DESC
LIMIT 1;
  ''');

    return x;
  }

  ResultSet getLogByDate(String date) {
    return _db.select(
        "select  logGift.*,gift.Name from logGift inner join gift on logGift.GiftId = gift.Id where DateOnly = '$date'");
  }

  ResultSet getDatesOfLog() {
    return _db.select(
        "select distinct DateOnly from logGift order by DateOnly desc ");
  }

  // void addToLog(int id) {
  //   _db.execute('''
  //     insert into logGift values('$formattedDate',$id,1)
  //     ''');
  // }
  void addToLog(int id) {
  _db.execute('''
    INSERT INTO logGift (DateOnly, GiftId, Count, Price)
    VALUES (
      '$formattedDate',
      $id,
      1,
      (
        SELECT  Price 
        FROM gift
        WHERE Id = $id
      )
    );
  ''');
}

  void updateLog({required int id, required int count}) {
    _db.execute('''
      update  logGift set
      count = $count
      where DateOnly = '$formattedDate'
      and GiftId =$id
      ''');
  }

  void updateLogCount({required int id, String sign = '+'}) {
    if (sign == '+' || sign == '-') {
      _db.execute('''
    update  logGift set Count = Count $sign 1 where
    GiftId = $id;
    ''');
    } else {
      print("invalid operation in update gift");
    }
  }

  void deleteFromLog(int id) {
    _db.execute('''
      delete from logGift where GiftId = $id and DateOnly = '$formattedDate'
      ''');
  }

  int thisDayCount({required int giftId}) {
    ResultSet x = _db.select(
        "select Count from logGift where GiftId =$giftId and DateOnly = '$formattedDate'");
    if (x.isEmpty) {
      return 0;
    }
    print(x);
    return x[0]['Count'];
  }

  void add({
    required String name,
    required int price,
    required int iconId,
  }) {
    _db.execute(
        "INSERT INTO gift('Name','Price','IconId') VALUES ('$name',$price,$iconId)");
  }

  void update(Gift gift) {
    "('Name','Category','IsBad','Price','IconId','Priority','Hardness','TimeInMinutes')";
    _db.execute('''UPDATE gift set Name = '${gift.name}',
  IconId = ${gift.iconId},
  Price = ${gift.price}
  WHERE Id = ${gift.id} ''');
  }

  void updateCount({required int id, String sign = '+'}) {
    if (sign == '+' || sign == '-') {
      _db.execute('''
    update  gift set NoOfUsed = NoOfUsed $sign 1 where
    Id = $id;
    ''');
    } else {
      print("invalid operation in update gift");
    }
  }

  void delete({required int id}) {
    _db.execute("delete from logGift where GiftId = $id");
    _db.execute("delete from gift where Id = $id");
  }

  void archive({required int id}) {
    _db.execute("update gift set IsArchived = 1  where Id = ?", [id]);
  }

  void restore({required int id}) {
    _db.execute("update gift set IsArchived = 0  where Id = ?", [id]);
  }
}

class CategoryFn {
  final Database _db;

  CategoryFn(this._db);

  ResultSet get() {
    return _db.select(
        "SELECT * FROM category ORDER BY CASE WHEN id = 1 THEN 0 ELSE 1 END, Level DESC;");
  }

  Row getById(int id) {
    return _db.select("select * from category where Id = $id")[0];
  }

  Row getByName({required String name}) {
    ResultSet result =
        _db.select("select * from category where Name = '$name'");
    return result[0];
  }

  void add({
    required String name,
    required int iconId,
  }) {
    _db.execute(
        "INSERT INTO category('Name','IconId') VALUES ('$name',$iconId)");
  }

  void delete({required int id}) {
    _db.execute("update habit set Category = 1 where Category = $id");
    _db.execute("delete from category where Id = $id");
  }

  update({required int id, required int iconId, required String name}) {
    print(iconId);
    _db.execute('''UPDATE category set Name = '$name',
  IconId = $iconId
  WHERE Id = $id ''');
  }

  int updateLevel({required int value, required int id}) {
    const mainCategoryId = 1;
    if(id != mainCategoryId){
      updateLevel(value: value,id: mainCategoryId);
    }
    Row res = _db.select("select * from category where id =$id")[0];
    Category category = Category(
        id: id,
        name: res['Name'],
        iconId: res['IconId'],
        earnedXp: res['EarnedXp'],
        level: res['Level'],
        maxXp: res['MaxXp']);
    bool isLevelIncrease = false;
    category.earnedXp += value;
    while (category.earnedXp >= category.maxXp) {
      category.earnedXp -= category.maxXp;
      category.maxXp = (category.maxXp * 1.25).toInt();
      category.level += 1;
      isLevelIncrease = true;
    }
    if (isLevelIncrease) {
      _db.execute(
          "update category set EarnedXp = ${category.earnedXp}, MaxXp = ${category.maxXp},Level = ${category.level} where Id = ${category.id} ");
      return category.level;
    }
    _db.execute(
        "update category set EarnedXp = EarnedXp + $value where Id = ${category.id}");
    return 0;
  }

  int? removeLevel({required int value, required int id}) {
    Row res = _db.select("select * from category where id =$id")[0];
    Category category = Category(
        id: id,
        name: res['Name'],
        iconId: res['IconId'],
        earnedXp: res['EarnedXp'],
        level: res['Level'],
        maxXp: res['MaxXp']);
    bool isLevelDecrease = false;
    category.earnedXp -= value;
    while (category.earnedXp < 0) {
      category.maxXp = (category.maxXp / 1.25).toInt();
      category.earnedXp += category.maxXp;
      category.level -= 1;
      isLevelDecrease = true;
    }
    if (isLevelDecrease) {
      _db.execute(
          "update category set EarnedXp = ${category.earnedXp}, MaxXp = ${category.maxXp},Level = ${category.level} where Id = ${category.id} ");
      return category.level;
    } else {
      _db.execute(
          "update category set EarnedXp = ${category.earnedXp} where Id = ${category.id}");
      return null;
    }
  }

  void updateCoins(int num) {
    _db.execute("update setting set Val =$num where Name = 'Coins'");
  }

  int getCoins() {
    ResultSet r = _db.select("select Val from setting where Name = 'Coins'");
    return r[0]["Val"];
  }
}

class SettingFn {
  final Database _db;

  SettingFn(this._db);

  void updateStreak() {
    DateTime lastDay =
        DateTime.parse(_getLastDay() ?? DateTime.now().toString());
    print(now.difference(lastDay).inDays);
    int diff = now.difference(lastDay).inDays;
    if (diff == 1) {
      _db.execute(
          '''UPDATE setting set Val = Val +1  WHERE Name = 'Streak' ''');
    } else if (diff != 0) {
      _db.execute('''UPDATE setting set Val = 1  WHERE Name = 'Streak' ''');
    }
  }

  int getStreak() {
    ResultSet r = _db.select("select Val from setting where Name = 'Streak'");
    return r[0]["Val"];
  }

  String? _getLastDay() {
    ResultSet r = _db
        .select("select DateOnly from logHabit Order by DateOnly DESC Limit 1");
    return r.isEmpty ? null : r[0]["DateOnly"];
  }

  int getAccentColorIndex() {
    var x =
        _db.select('''SELECT Val from setting where Name = 'AccentColor' ''');
    return x[0]['Val'];
  }

  void setAccentColor(val) {
    _db.execute("UPDATE setting set Val = $val WHERE Name = 'AccentColor' ");
  }

  bool getDarkMode() {
    var x = _db.select('''SELECT Val from setting where Name = 'DarkMode' ''');
    if (x[0]['Val'] == 1) {
      return true;
    } else {
      return false;
    }
  }

  void setDarkMode(val) {
    _db.execute("UPDATE setting set Val = $val WHERE Name = 'DarkMode' ");
  }

  bool isListView() {
    var x = _db.select('''SELECT Val from setting where Name = 'ListView' ''');
    if (x[0]['Val'] == 1) {
      return true;
    } else {
      return false;
    }
  }

  void setIsListView(bool val) {
    _db.execute(
        "UPDATE setting set Val = ${val ? 1 : 0} WHERE Name = 'ListView' ");
  }

  getNotificationTime() {
    var x = _db
        .select('''SELECT Val from setting where Name = 'NotificationTime' ''');
    return x[0]['Val'];
  }

  void setNotificationTime(/*TimeOfDay*/ time) {
    int val = time.hour * 60 + time.minute;
    _db.execute(
        "UPDATE setting set Val = $val WHERE Name = 'NotificationTime' ");
  }
  void setNotificationTimeToFalse(){
    var val = -1;
    _db.execute(
        "UPDATE setting set Val = $val WHERE Name = 'NotificationTime' ");

  }

  int getLanguageId() {
    var x = _db.select('''SELECT Val from setting where Name = 'LanguageId' ''');
    if(x.isNotEmpty){
      print("language id is ${x[0]['Val']}");
      return x[0]['Val'];
    }
    print("x is $x");
    return 0;
  }

  void setLanguageId(langId){
    _db.execute("UPDATE setting set Val = $langId WHERE Name = 'LanguageId' ");
  }

  int getEasterEggs(){
    var x = _db.select('''SELECT Val from setting where Name = 'EasterEggs' ''');
    if(x.isNotEmpty){
      return x[0]['Val'];
    }
    return 0;
  }
  void foundEasterEggs(){
    _db.execute("UPDATE setting set Val = Val +1 WHERE Name = 'EasterEggs' ");
  }

  int getDBVersion(){
    var x = _db.select('''SELECT Val from setting where Name = 'DBVersion' ''');
    if(x.isNotEmpty){
      return x[0]['Val'];
    }
    return 0;
  }
  void setDBVersionToLatest() {
    _db.execute("UPDATE setting set Val = $kDBVersion WHERE Name = 'DBVersion' ");
  }
}

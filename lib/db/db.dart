import 'dart:io';

import '../config/const.dart';
import 'sql_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';


class DbHelper {
  final _supportDir = getApplicationSupportDirectory();
  late final String dbPath;

  late Database db;
  late Sql sql;

  Future<void> openDb() async {
   
      final dir = await _supportDir;
    dbPath = "${dir.path}/hcody_ab.db";
    print(dbPath);
    _restoreIfExists();
    db = sqlite3.open(dbPath);
    dbMigration(db);
    sql = Sql(db);
    sql.settings.updateStreak();
  }

  void _restoreIfExists() async {
    var dir = await _supportDir;
    File restored = File('${dir.path}/restored.db');
    if (await restored.exists()) {
      print("restoring");
      File old = File(dbPath);
      await old.delete();
      await restored.rename(dbPath);
    }
  }

  void dbMigration(Database db) {
    const String createCategoryTable = '''
  CREATE TABLE IF NOT EXISTS category(
  Id INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT unique,
  IconId INTEGER DEFAULT 0,
  EarnedXp INTEGER DEFAULT 0,
  MaxXp INTEGER DEFAULT 100,
  Level INTEGER DEFAULT 1
  );
  INSERT OR IGNORE INTO  category (Name) values('main');
  ''';
    const String createHabitTable = '''
  CREATE TABLE IF NOT EXISTS habit(
  Id INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT,
  Category INTEGER,
  IsBad BOOLEAN,
  Price int,
  IconId INTEGER,
  Priority INTEGER,
  Hardness INTEGER,
  TimeInMinutes INTEGER,
  IsArchived BOOLEAN DEFAULT 0,
  FOREIGN KEY(Category) REFERENCES category(Id)
  )''';
    const String createGiftTable = '''
  CREATE TABLE IF NOT EXISTS gift(
  Id INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT,
  Price INTEGER,
  IconId INTEGER,
  IsArchived BOOLEAN DEFAULT 0,
  NoOfUsed INTEGER DEFAULT 0
  )

  ''';
    const String createSettingTable = '''
  CREATE TABLE IF NOT EXISTS setting(
  Id INTEGER PRIMARY KEY,
  Name TEXT,
  Val INTEGER
  );
  INSERT OR IGNORE INTO setting(Id,Name,Val) values (1,'Coins',0),(2,'DarkMode',0),(3,'AccentColor',0),(4,'NotificationTime',-1),(5,'Streak',1),(6,'ListView',0),(7,'LanguageId',0),(8,'EasterEggs',0),(9,'DBVersion',1);
  
    ''';
    const String createLogGiftTable = '''
  CREATE TABLE IF NOT EXISTS logGift(
  DateOnly TEXT,
  GiftId INTEGER, 
  Count INTEGER,
  PRIMARY KEY (GiftId, DateOnly),
  FOREIGN KEY (GiftId) REFERENCES gift(Id)
  )''';
    const String createLogHabitTable = '''
  CREATE TABLE IF NOT EXISTS logHabit(
  DateOnly TEXT,
  HabitId INTEGER, 
  Count INTEGER,
  PRIMARY KEY (HabitId, DateOnly),
  FOREIGN KEY (HabitId) REFERENCES habit(Id)
  )''';

    const addPriceToLogHabitTable =
        "ALTER TABLE logHabit ADD COLUMN Price INTEGER;";
    const addPriceToLogGiftTable =
        "ALTER TABLE logGift ADD COLUMN Price INTEGER;";

    const addPriceValuesToLogHabitTable = '''
      UPDATE logHabit
      SET Price = (
      SELECT CASE 
           WHEN h.IsBad = 1 THEN -1 * h.Price 
           ELSE h.Price 
         END
      FROM habit h 
      WHERE h.Id = logHabit.HabitId
      )
      WHERE Price IS NULL;
    ''';

    const addPriceValuesToLogGiftTable = '''
    UPDATE logGift
    SET Price = (
    SELECT g.Price FROM gift g WHERE g.Id = logGift.GiftId
    )
    WHERE Price IS NULL;
      ''';

    const Map<int, List<String>> sqlList = {
      1: [
        createCategoryTable,
        createHabitTable,
        createGiftTable,
        createLogGiftTable,
        createLogHabitTable,
        createSettingTable
      ],
      2: [
        addPriceToLogHabitTable,
        addPriceToLogGiftTable,
        addPriceValuesToLogHabitTable,
        addPriceValuesToLogGiftTable
      ]
    };

    int currentVersion = getCurrentVersion(db);
    print("Current DB Version: $currentVersion");
    for (int version = currentVersion + 1; version <= kDBVersion; version++) {
      final List<String>? migrationScripts = sqlList[version];
      if (migrationScripts != null) {
        for (final sql in migrationScripts) {
          db.execute(sql);
        }
      }
    }
    setDBVersionToLatest(db);
  }
}

var db = DbHelper();
int getCurrentVersion(Database db) {
  try{
  var x = db.select('''SELECT Val from setting where Name = 'DBVersion' ''');
    if(x.isNotEmpty){
      return x[0]['Val'];
    }}catch (e) {
      print("Error getting DB version: $e");
    }
    return 0;
}

void setDBVersionToLatest(Database db) {
  db.execute("UPDATE setting set Val = $kDBVersion WHERE Name = 'DBVersion' ");
}

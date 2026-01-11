import 'package:achievement_box/services/notification_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // Add this package to pubspec.yaml
import 'package:achievement_box/rootProvider/locale_provider.dart';
import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages (depends on the  Delegates)
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/homePage/Bodies/HomeBody/provider/levelProvider.dart';
import 'pages/homePage/Bodies/providers/coinsProvider.dart';
import 'pages/homePage/Bodies/providers/pageIndexProvider.dart';
import 'pages/homePage/homePage.dart';
import 'rootProvider/settings_controller.dart';
import 'config/app_theme.dart';
import 'db/db.dart';
import 'rootProvider/ThemeProvider.dart';
import 'rootProvider/categoryProvider.dart';
import 'rootProvider/giftProvider.dart';
import 'rootProvider/habitProvider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.openDb();
  SettingsController.appVersion = (await PackageInfo.fromPlatform()).version;
  await NotificationService().init();
  await Translate.init(defaultLangCode: 'en');
  await Translate.setLang(Translate.supportedLangs[db.sql.settings.getLanguageId()]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LevelProvider()),
          ChangeNotifierProvider(
            create: (context) => HabitProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
          ),
          Provider(
            create: (context) => LocaleProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => CoinsProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => GiftProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => CategoryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => PageIndexProvider(),
          )
        ],
        child: Builder(builder: (context) {
          bool isDarkMode = db.sql.settings.getDarkMode();
          Color accentColor = context.watch<ThemeProvider>().AccentColor;
          //  var c= context.watch<LocaleProvider>().Language;

          return MaterialApp(
            title: 'Achievement Box',
            locale: Locale(context.read<LocaleProvider>().Language.toLowerCase()),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales:
            Translate.supportedLangs.map((lang) => Locale(lang)),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(accentColor, isDarkMode),
            home: HomePage(title: tr("appName")),
          );
        }));
  }
}
// TODO show data about the habit or gift purchased dates

// TODO edit page if is archived show delete or restore

// todo refactor db sql injection err
// todo last refactor
// todo adding the welcome for new users
import 'package:flutter/material.dart';

import '../db/db.dart';
import '../output/generated/colors.dart';
import 'const.dart';

ThemeData buildTheme(Color accentColor, bool isDark) {
  final ThemeData base = isDark ? ThemeData.dark() : ThemeData.light();
  Color backgroundColor = isDark ? kDarkGrey : kWhite;
  Color primaryColor = accentColor;
  print(primaryColor);
  final swatch = ColorScheme.fromSwatch(
      primarySwatch: colors[db.sql.settings.getAccentColorIndex()],
      brightness: isDark ? Brightness.dark : Brightness.light);
  return base.copyWith(
    tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
    dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
            alignment: const Alignment(-1, 1.3),
            surfaceTintColor: WidgetStatePropertyAll(primaryColor),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(backgroundColor),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: primaryColor, width: 2),
            )))),
    segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
            side: const BorderSide(width: 1.5, color: Colors.transparent),
            selectedBackgroundColor: swatch.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
            ))),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        elevation: 0,
        unselectedItemColor: Colors.grey,
        selectedItemColor: swatch.primary,
        selectedLabelStyle: TextStyle(color: swatch.primary)),
    switchTheme: SwitchThemeData(
      trackOutlineColor:
          WidgetStatePropertyAll(swatch.primary.withValues(alpha: 0.2)),
      thumbColor: WidgetStatePropertyAll(swatch.primary.withValues(alpha:0.2)),
    ),
    dialogTheme:
        DialogThemeData(backgroundColor: isDark ? Colors.black : Colors.white),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            iconColor: WidgetStatePropertyAll(
      swatch.primary,
    ))),
    inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: isDark ? Colors.white : Colors.black)),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(TextStyle(
      color:swatch.primary,

      fontFamily: "Dubai",
    )))),
    scaffoldBackgroundColor: isDark ? kDarkGrey : kWhite,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(),
        backgroundColor: swatch.primary.withValues(alpha:0.9),
        elevation: 0,
        hoverElevation: 0),
    iconTheme: IconThemeData(
      color: swatch.primary,
    ),
    colorScheme: swatch,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? kDarkGrey : kWhite,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: "Dubai",
        fontSize: 20,
        color: swatch.primary,
      ),
      centerTitle: true,
    ),
    hintColor: accentColor,
    cardColor: primaryColor,
    primaryColor: primaryColor,
    primaryIconTheme: base.primaryIconTheme.copyWith(
      color: accentColor,
    ),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme, accentColor),
    textSelectionTheme:
        _buildTextSelectionTheme(base.textSelectionTheme, accentColor, isDark),
    textTheme: _buildTextTheme(base.textTheme, accentColor),
  );
}

TextTheme _buildTextTheme(TextTheme base, Color color) {
  return base.copyWith(
    bodyMedium: base.bodyMedium!.copyWith(fontSize: 16, fontFamily: "Dubai"),
    bodyLarge: base.bodyLarge!.copyWith(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: "Dubai"),
    labelLarge: base.labelLarge!.copyWith(color: color, fontFamily: "Dubai"),
    bodySmall: base.bodySmall!
        .copyWith(color: color, fontSize: 14, fontFamily: "Dubai"),
    headlineSmall: base.headlineSmall!
        .copyWith(color: color, fontSize: 22, fontFamily: "Dubai"),
    titleMedium: base.titleMedium!
        .copyWith(color: color, fontSize: 16, fontFamily: "Dubai"),
    titleLarge: base.titleLarge!.copyWith(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: "Dubai"),
  );
}

TextSelectionThemeData _buildTextSelectionTheme(
    TextSelectionThemeData base, Color accentColor, bool isDark) {
  return base.copyWith(
    cursorColor: accentColor,
    selectionColor: isDark ? kDarkGrey : kLightGrey,
    selectionHandleColor: accentColor,
  );
}

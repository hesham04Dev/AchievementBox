import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:provider/provider.dart';

import '../../../../models/imageIcon.dart';
import '../../../../rootProvider/ThemeProvider.dart';
import '../Bodies/providers/pageIndexProvider.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    var bodiesController =
        Provider.of<PageIndexProvider>(context, listen: false).bodiesController;
    var pageIndex = context.watch<PageIndexProvider>().pageIndex;
    Color accentColor = context.watch<ThemeProvider>().AccentColor;
    return BottomNavigationBar(
      currentIndex: pageIndex,
      iconSize: 25,
      onTap: (value) {
        setState(() {
          bodiesController.jumpToPage(value);
        });
      },
      items: [
        BottomNavigationBarItem(
            icon: IconImage(
              color: accentColor.withOpacity(0.8),
              iconName: "gear.png",
            ),
            label: tr("settings")),
        BottomNavigationBarItem(
            icon: IconImage(
              color: accentColor.withOpacity(0.8),
              iconName: "igloo.png",
            ),
            label: tr("home")),
        BottomNavigationBarItem(
            icon: IconImage(
              color: accentColor.withOpacity(0.8),
              iconName: "gift.png",
            ),
            label: tr("gifts")),
        BottomNavigationBarItem(
            icon: IconImage(
                color: accentColor.withOpacity(0.8),
                iconName: "chart-simple.png"),
            label: tr("statistics")),
      ],
    );
  }
}

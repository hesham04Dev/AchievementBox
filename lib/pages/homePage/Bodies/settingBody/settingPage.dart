import 'package:achievement_box/config/const.dart';
import 'package:achievement_box/models/my_toast.dart';
import 'package:achievement_box/rootProvider/locale_provider.dart';
import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";

import 'package:mailto/mailto.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../db/db.dart';
import '../../../../rootProvider/ThemeProvider.dart';
import '../../../logPage/log_page.dart';
import '../../../../models/imageIcon.dart';
import '../../../../models/mySwitchTile.dart';
import '../../../../pages/ArchivePage/archivePage.dart';
import '../../../../pages/homePage/Bodies/settingBody/Widget/ColorDialog.dart';
import '../../../../pages/homePage/Bodies/settingBody/Widget/MyListTile.dart';
import '../../../../pages/homePage/Bodies/settingBody/Widget/backup.dart';
import '../../../../rootProvider/settings_controller.dart';

import 'Widget/lang_dialog.dart';
import 'Widget/restore_tile.dart';

import '../../../../services/notification_service.dart';
class SettingBody extends StatefulWidget {
  const SettingBody({super.key});

  @override
  State<SettingBody> createState() => _SettingBodyState();
}

class _SettingBodyState extends State<SettingBody> {
  @override
  Widget build(BuildContext context) {
    Widget darkModeTile = MySwitchTile(
      title: tr("darkMode"),
      value: db.sql.settings.getDarkMode(),
      onChange: (bool value) {
        value ? db.sql.settings.setDarkMode(1) : db.sql.settings.setDarkMode(0);
        context.read<ThemeProvider>().toggleMode();
      },
    );
    Widget listViewTile = MySwitchTile(
      title: tr("listView"),
      value: db.sql.settings.isListView(),
      onChange: (bool value) {
        db.sql.settings.setIsListView(value);
        context.read<ThemeProvider>().toggleMode();
      },
    );

    int notificationTime = db.sql.settings.getNotificationTime();
    bool isNotificationEnabled = notificationTime != -1;
    TimeOfDay selectedTime = isNotificationEnabled
        ? TimeOfDay(hour: notificationTime ~/ 60, minute: notificationTime % 60)
        : const TimeOfDay(hour: 9, minute: 0);

    Widget notificationTile = Column(
      children: [
        MySwitchTile(
          title: tr("daily_notification"),
          value: isNotificationEnabled,
          onChange: (bool isEnabled) async {
            if (isEnabled) {
              NotificationService().requestNotificationsPermission();
              db.sql.settings.setNotificationTime(selectedTime);
              await NotificationService().scheduleDailyNotification(selectedTime);
            } else {
              db.sql.settings.setNotificationTimeToFalse();
              await NotificationService().cancelNotifications();
            }
            setState(() {});
          },
        ),
        if (isNotificationEnabled)
          MyListTile(
            title: tr("notification_time"),
            trailing: Text(
              selectedTime.format(context),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (picked != null && picked != selectedTime) {
                db.sql.settings.setNotificationTime(picked);
                await NotificationService().scheduleDailyNotification(picked);
                setState(() {});
              }
            },
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          listViewTile,
          darkModeTile,
          notificationTile,
          MyListTile(
            title: tr('accentColor'),
            trailing: IconImage(
              iconName: "circle.png",
            ),
            onTap: () {
              showDialog(context: context, builder: (context) => const ColorDialog(key: Key("colorDialog"),));
            },
          ),
          MyListTile(
            title: tr('language'),
            trailing: Text(
             context.read<LocaleProvider>().Language,
             style: const TextStyle(fontSize: 16),
            ),
            onTap: () {
              showDialog(context: context, builder: (context) =>const LangDialog(key: Key("langDialog"),));
            },
          ),
          BackupTile(),
          /*not constant*/
          RestoreTile(),
          /*not constant*/
          MyListTile(
            title: tr('viewOnGithub'),
            trailing: IconImage(
              iconName: "github-alt.png",
            ),
            onTap: () async {
              await  launchUrl(Uri.parse('https://github.com/hesham04Dev/AchievementBox'));
            },
          ),
          MyListTile(
              title: tr("logPage"),
              trailing: IconImage(
                iconName: "rectangle-history.png",
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LogPage()));
              }),
          MyListTile(
              title: tr("archivePage"),
              trailing: IconImage(
                iconName: "box-archive.png",
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ArchivePage()));
              }),
          MyListTile(
              title: tr("reportErrorInTranslation"),
              trailing: IconImage(
                iconName: "bug.png",
              ),
              onTap: () async {
                final mailtoLink = Mailto(
                  to: [kEmail],
                  subject: 'Report Error in Translation',
                  body: 'eg: [قائمة الطعام] should be القائمة',
                );

                await launchUrl(Uri.parse('$mailtoLink'));
              }),
          MyListTile(
            title: '${tr("version")}: ${SettingsController.appVersion}',
            onTap: () {
              if(db.sql.settings.getEasterEggs() ==1){
                MyToast(title:const Text("1"),).show(context);
                db.sql.settings.foundEasterEggs();
              }
              
            },
          ),
        ],
      ),
    );
  }
}

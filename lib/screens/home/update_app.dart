import 'dart:io';

import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/home/UserLocationChecker.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/db/models/chipchop_config.dart';
import 'package:chipchop_buyer/screens/Home/do_not_show_again_dialog.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateApp extends StatefulWidget {

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  String url = "";

  @override
  void initState() {
    super.initState();

    checkLatestVersion(context);
  }

  checkLatestVersion(context) async {
    SharedPreferences sPref = await SharedPreferences.getInstance();

    ChipChopConfig conf =
        await ChipChopConfig().getConfigByPlatform(Platform.operatingSystem);
    if (conf == null)
      return;
      
    url = conf.appURL;

    await sPref.setInt('referral_bonus', conf.referralBonus ?? 25);
    await sPref.setInt('registration_bonus', conf.registrationBonus ?? 25);

    Version minAppVersion = Version.parse(conf.minVersion);
    Version latestAppVersion = Version.parse(conf.cVersion);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(packageInfo.version);

    if (minAppVersion > currentVersion) {
      _showCompulsoryUpdateDialog(
          context, "Please update the app to continue\n");
    } else if (latestAppVersion > currentVersion) {
      bool showUpdates = sPref.getBool('update_do_not_ask');
      if (showUpdates != null && showUpdates == false) {
        return;
      }

      _showOptionalUpdateDialog(
          context, "A newer version of the app is available\n");
    }
  }

  _showOptionalUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        String btnLabelDontAskAgain = "Don't ask me again";
        return DoNotAskAgainDialog(
          'update_do_not_ask',
          title,
          message,
          btnLabel,
          btnLabelCancel,
          url,
          doNotAskAgainText:
              Platform.isIOS ? btnLabelDontAskAgain : 'Never ask again',
        );
      },
    );
  }

  Future<void> _onUpdateNowClicked() async {
    try {
      await UrlLauncherUtils.launchURL(url);
    } catch (err) {
      CustomDialogs.waiting(context, "Error!",
          "Unable to open update URL now. Please update manually!");
    }
  }

  _showCompulsoryUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      btnLabel,
                    ),
                    isDefaultAction: true,
                    onPressed: () async {
                      await _onUpdateNowClicked();
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: Text(
                  title,
                  style: TextStyle(fontSize: 22),
                ),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () async {
                      await _onUpdateNowClicked();
                    },
                  ),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return cachedLocalUser.primaryLocation != null
        ? HomeScreen()
        : UserLocationChecker();
  }
}

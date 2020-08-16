import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/app/ContactAndSupportWidget.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/settings/SettingsHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import '../../app_localizations.dart';

Widget sideDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(
              color: CustomColors.mfinBlue,
            ),
            child: Container()),
        ListTile(
            leading: Icon(Icons.home, color: CustomColors.mfinButtonGreen),
            title: Text(
              "Home",
            ),
            onTap: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                  settings: RouteSettings(name: '/home'),
                ),
                (Route<dynamic> route) => false,
              );
            }),
        Divider(indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
        ExpansionTile(
          title: Text(
            "Orders",
          ),
          leading:
              Icon(Icons.content_copy, color: CustomColors.mfinButtonGreen),
          children: <Widget>[
            ListTile(
              title: Text(
                "Active Orders",
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
            ListTile(
              title: Text(
                "History",
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.supervisor_account,
              color: CustomColors.mfinButtonGreen),
          title: Text(
            "Products",
          ),
          children: <Widget>[
            ListTile(
              title: Text(
                "Add Product",
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
            ListTile(
              title: Text(
                "View Product",
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        Divider(indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.notifications_active,
              color: CustomColors.mfinButtonGreen),
          title: Text(
            "Notifications",
          ),
        ),
        Divider(indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.settings, color: CustomColors.mfinButtonGreen),
          title: Text(
            AppLocalizations.of(context).translate('profile_settings'),
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsHome(),
                settings: RouteSettings(name: '/settings'),
              ),
            );
          },
        ),
        Divider(indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.headset_mic, color: CustomColors.mfinButtonGreen),
          title: Text(
            AppLocalizations.of(context).translate('help_and_support'),
          ),
          onTap: () {
            showDialog(
              context: context,
              routeSettings: RouteSettings(name: "/home/help"),
              builder: (context) {
                return Center(
                  child: contactAndSupportDialog(context),
                );
              },
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.error, color: CustomColors.buyerAlertRed),
          title: Text(
            AppLocalizations.of(context).translate('logout'),
          ),
          onTap: () => CustomDialogs.confirm(
              context,
              AppLocalizations.of(context).translate('warning'),
              AppLocalizations.of(context).translate('logout_message'),
              () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AuthPage(),
                settings: RouteSettings(name: '/logout'),
              ),
              (Route<dynamic> route) => false,
            );
          }, () => Navigator.pop(context, false)),
        ),
        Container(
          color: CustomColors.mfinBlue,
          child: AboutListTile(
            dense: true,
            applicationIcon: Container(
              height: 80,
              width: 50,
              child: ClipRRect(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/icons/logo.png',
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
            ),
            applicationName: 'ChipChop',
            applicationLegalese:
                AppLocalizations.of(context).translate('copyright'),
            child: ListTile(
              leading: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: '',
                  style: TextStyle(
                    color: CustomColors.mfinLightBlue,
                    fontFamily: 'Georgia',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'ChipChop',
                      style: TextStyle(
                        color: CustomColors.mfinFadedButtonGreen,
                        fontFamily: 'Georgia',
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            aboutBoxChildren: <Widget>[
              SizedBox(
                height: 20,
              ),
              Divider(),
              ListTile(
                leading: Text(
                  'ChipChop',
                  style: TextStyle(
                    color: CustomColors.mfinBlue,
                    fontFamily: 'Georgia',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: CustomColors.mfinBlue,
                  size: 35.0,
                ),
                title: Text(
                  AppLocalizations.of(context)
                      .translate('terms_and_conditions'),
                  style: TextStyle(
                    color: CustomColors.mfinLightBlue,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(),
            ],
          ),
        ),
      ],
    ),
  );
}

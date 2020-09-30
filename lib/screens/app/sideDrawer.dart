import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/app/ContactAndSupportWidget.dart';
import 'package:chipchop_buyer/screens/app/ProfilePictureUpload.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_buyer/screens/settings/SettingsHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/hash_generator.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import '../../app_localizations.dart';

Widget sideDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: CustomColors.green,
          ),
          child: Column(
            children: <Widget>[
              Container(
                child: cachedLocalUser.getProfilePicPath() == ""
                    ? Container(
                        width: 90,
                        height: 90,
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomColors.blueGreen,
                            style: BorderStyle.solid,
                            width: 2.0,
                          ),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              routeSettings:
                                  RouteSettings(name: "/profile/upload"),
                              builder: (context) {
                                return Center(
                                  child: ProfilePictureUpload(
                                      0,
                                      cachedLocalUser.getMediumProfilePicPath(),
                                      HashGenerator.hmacGenerator(
                                          cachedLocalUser.getID(),
                                          cachedLocalUser
                                              .createdAt.millisecondsSinceEpoch
                                              .toString()),
                                      cachedLocalUser.getIntID()),
                                );
                              },
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.person,
                                  size: 45.0,
                                  color: CustomColors.blueGreen,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('upload'),
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: CustomColors.lightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        child: Stack(
                          children: <Widget>[
                            SizedBox(
                              width: 95.0,
                              height: 95.0,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      cachedLocalUser.getMediumProfilePicPath(),
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    radius: 45.0,
                                    backgroundImage: imageProvider,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 35,
                                  ),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 2),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -8,
                              left: 35,
                              child: FlatButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    routeSettings:
                                        RouteSettings(name: "/profile/upload"),
                                    builder: (context) {
                                      return Center(
                                        child: ProfilePictureUpload(
                                            0,
                                            cachedLocalUser
                                                .getMediumProfilePicPath(),
                                            HashGenerator.hmacGenerator(
                                                cachedLocalUser.getID(),
                                                cachedLocalUser.createdAt
                                                    .millisecondsSinceEpoch
                                                    .toString()),
                                            cachedLocalUser.getIntID()),
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: CustomColors.blueGreen,
                                  radius: 15,
                                  child: Icon(
                                    Icons.edit,
                                    color: CustomColors.lightGrey,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Text(
                cachedLocalUser.firstName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.lightGrey,
                ),
              ),
              Text(
                cachedLocalUser.mobileNumber.toString(),
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.lightGrey,
                ),
              ),
            ],
          ),
        ),
        ListTile(
            leading: Icon(Icons.home, color: CustomColors.blueGreen),
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
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.content_copy, color: CustomColors.blueGreen),
          title: Text(
            "Orders",
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrdersHomeScreen(),
                settings: RouteSettings(name: '/orders'),
              ),
            );
          },
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading:
              Icon(Icons.notifications_active, color: CustomColors.blueGreen),
          title: Text(
            "Notifications",
          ),
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.settings, color: CustomColors.blueGreen),
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
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.headset_mic, color: CustomColors.blueGreen),
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
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.error, color: CustomColors.alertRed),
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
        Divider(color: CustomColors.blue, thickness: 1.0),
        Container(
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
            applicationName: 'Uniques',
            applicationLegalese:
                AppLocalizations.of(context).translate('copyright'),
            child: ListTile(
              leading: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: '',
                  style: TextStyle(
                    color: CustomColors.lightBlue,
                    fontFamily: 'Georgia',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Uniques',
                      style: TextStyle(
                        color: CustomColors.green,
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
                  'Uniques',
                  style: TextStyle(
                    color: CustomColors.blue,
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
                  color: CustomColors.blue,
                  size: 35.0,
                ),
                title: Text(
                  AppLocalizations.of(context)
                      .translate('terms_and_conditions'),
                  style: TextStyle(
                    color: CustomColors.lightBlue,
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

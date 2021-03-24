import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/app/ContactAndSupportWidget.dart';
import 'package:chipchop_buyer/screens/app/ProfilePictureUpload.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_buyer/screens/settings/WalletHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:chipchop_buyer/services/utils/hash_generator.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';

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
                        width: 80,
                        height: 80,
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomColors.alertRed,
                            style: BorderStyle.solid,
                            width: 2.0,
                          ),
                        ),
                        child: TextButton(
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
                                  size: 35.0,
                                  color: CustomColors.blueGreen,
                                ),
                              ),
                              Text(
                                "Upload",
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
                              width: 90.0,
                              height: 90.0,
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
                              left: 30,
                              child: TextButton(
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
                                  backgroundColor: CustomColors.alertRed,
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
            leading: Icon(Icons.home, color: CustomColors.green),
            title: Text(
              "Home",
            ),
            onTap: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(0),
                  settings: RouteSettings(name: '/home'),
                ),
                (Route<dynamic> route) => false,
              );
            }),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.search, color: CustomColors.green),
          title: Text(
            "Search",
          ),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(1),
                settings: RouteSettings(name: '/search'),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.content_copy, color: CustomColors.green),
          title: Text(
            "Orders",
          ),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(3),
                settings: RouteSettings(name: '/orders'),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.settings, color: CustomColors.green),
          title: Text(
            "Profile Settings",
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSetting(),
                settings: RouteSettings(name: '/settings/profile'),
              ),
            );
          },
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading:
              Icon(Icons.account_balance_wallet, color: CustomColors.green),
          title: Text(
            "User Wallet",
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletHome(),
                settings: RouteSettings(name: '/settings/wallet'),
              ),
            );
          },
        ),
        Divider(indent: 65.0, color: CustomColors.blue, thickness: 1.0),
        ListTile(
          leading: Icon(Icons.headset_mic, color: CustomColors.green),
          title: Text(
            "Help and Support",
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
            "Logout",
          ),
          onTap: () => CustomDialogs.confirm(
              context, "Warning!", "Do you really want to Logout?", () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AuthPage(
                    cachedLocalUser.getID(),
                    cachedLocalUser.firstName +
                            ' ' +
                            cachedLocalUser.lastName ??
                        "",
                    cachedLocalUser.getSmallProfilePicPath()),
                settings: RouteSettings(name: '/logout'),
              ),
              (Route<dynamic> route) => false,
            );
          }, () => Navigator.pop(context, false)),
        ),
        Divider(color: CustomColors.blue, thickness: 1.0),
        Container(
          child: AboutListTile(
            applicationIcon: ClipRRect(
              child: Image.asset(
                'images/icons/logo.png',
                height: 40,
                width: 40,
              ),
            ),
            applicationName: buyer_app_name,
            applicationVersion: app_version,
            applicationLegalese: "© 2020 Fourcup Inc.",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    buyer_app_name,
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontFamily: "OLED",
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    app_version,
                    style: TextStyle(
                      color: CustomColors.green,
                      fontFamily: "OLED",
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
            aboutBoxChildren: <Widget>[
              SizedBox(
                height: 20,
              ),
              Divider(),
              ListTile(
                leading: Text(""),
                title: Text(
                  buyer_app_name,
                  style: TextStyle(
                    color: CustomColors.blue,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: CustomColors.blue,
                  size: 35.0,
                ),
                title: Text(
                  "Terms of Services",
                  style: TextStyle(
                    color: CustomColors.lightBlue,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                height: 0,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

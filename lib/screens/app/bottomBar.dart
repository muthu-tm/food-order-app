import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_buyer/screens/search/search_home.dart';
import 'package:chipchop_buyer/screens/settings/SettingsHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

Widget bottomBar(BuildContext context) {
  Size size = Size(screenWidth(context, dividedBy: 4), 100);

  return Container(
    height: 60,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [CustomColors.white, CustomColors.green],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                    settings: RouteSettings(name: '/'),
                  ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.home,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "HOME",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchHome(),
                  settings: RouteSettings(name: '/search'),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.search,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "SEARCH",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersHomeScreen(),
                  settings: RouteSettings(name: '/orders'),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.content_copy,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "ORDERS",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsHome(),
                    settings: RouteSettings(name: '/settings'),
                  ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.settings,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "SETTINGS",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

double screenWidth(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).width / dividedBy;
}

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).height / dividedBy;
}

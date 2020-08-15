import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/settings/SettingsHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';

Widget bottomBar(BuildContext context) {
  Size size = Size(screenWidth(context, dividedBy: 4), 100);

  return Container(
    height: 70,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox.fromSize(
          size: size,
          child: Material(
            color: CustomColors.mfinBlue,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                    settings: RouteSettings(name: '/'),
                  )
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.home,
                    size: 30.0,
                    color: CustomColors.mfinButtonGreen,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('home'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontSize: 12,
                      color: CustomColors.buyerGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: Material(
            color: CustomColors.mfinBlue,
            child: InkWell(
              onTap: () {
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TransactionScreen(),
                //     settings: RouteSettings(name: '/orders'),
                //   ),
                //   (Route<dynamic> route) => false,
                // );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    size: 30.0,
                    color: CustomColors.mfinButtonGreen,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('search'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontSize: 12,
                      color: CustomColors.buyerGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: Material(
            color: CustomColors.mfinBlue,
            child: InkWell(
              onTap: () {
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TransactionScreen(),
                //     settings: RouteSettings(name: '/orders'),
                //   ),
                //   (Route<dynamic> route) => false,
                // );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.content_copy,
                    size: 30.0,
                    color: CustomColors.mfinButtonGreen,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('orders'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontSize: 12,
                      color: CustomColors.buyerGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: Material(
            color: CustomColors.mfinBlue,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsHome(),
                    settings: RouteSettings(name: '/settings'),
                  )
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.settings,
                    size: 30.0,
                    color: CustomColors.mfinButtonGreen,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('settings'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontSize: 12,
                      color: CustomColors.buyerGrey,
                    ),
                  ),
                ],
              ),
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

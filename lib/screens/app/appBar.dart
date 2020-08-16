import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return AppBar(
    backgroundColor: CustomColors.mfinBlue,
    titleSpacing: 0.0,
    automaticallyImplyLeading: false,
    title: Builder(
      builder: (context) => InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: Container(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.menu,
            size: 30.0,
            color: CustomColors.buyerWhite,
          ),
        ),
      ),
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.shopping_cart,
          size: 30.0,
          color: CustomColors.buyerWhite,
        ),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SearchAppBar(),
          //     settings: RouteSettings(name: '/Search'),
          //   ),
          // );
        },
      ),
      // PushNotification(),
    ],
  );
}

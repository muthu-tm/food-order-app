import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/user/ViewLocationsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  Widget getLocation() {
    return cachedLocalUser.primaryLocation == null
        ? InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                  settings: RouteSettings(name: '/location/add'),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text(
                    "Add Location",
                    style: TextStyle(color: CustomColors.black),
                  ),
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewLocationsScreen(),
                  settings: RouteSettings(name: '/location'),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text(
                    "${cachedLocalUser.primaryLocation.locationName}",
                    style: TextStyle(color: CustomColors.black),
                  ),
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          );
  }

  return AppBar(
    backgroundColor: CustomColors.green,
    titleSpacing: 0.0,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: EdgeInsets.only(left: 5.0),
              child: Icon(
                Icons.menu,
                size: 30.0,
                color: CustomColors.black,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
          "Uniques",
          style: TextStyle(
              fontFamily: "OLED",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ],
    ),
    actions: <Widget>[
      getLocation(),
      IconButton(
        icon: Icon(
          Icons.shopping_cart,
          size: 30.0,
          color: CustomColors.black,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShoppingCartScreen(),
              settings: RouteSettings(name: '/cart'),
            ),
          );
        },
      ),
    ],
  );
}

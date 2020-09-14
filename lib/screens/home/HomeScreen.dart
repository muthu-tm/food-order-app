import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/user/NearByStores.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      backgroundColor: CustomColors.buyerWhite,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 250,
                    decoration: BoxDecoration(
                        border: Border.all(color: CustomColors.buyerBlack)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.location_on,
                                size: 20,
                                color: CustomColors.buyerPositiveGreen)),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: getLocation(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Orders",
                    style: TextStyle(
                        fontFamily: "Georgia",
                        color: CustomColors.buyerGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: getOrdersCard(context),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Top Store Categories",
                    style: TextStyle(
                        fontFamily: "Georgia",
                        color: CustomColors.buyerGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: getCategoryCards(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getLocation() {
    return FutureBuilder(
      future: cachedLocalUser.getLocations(),
      builder: (context, AsyncSnapshot<List<UserLocations>> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.length == 0) {
            child = InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLocation(),
                    settings: RouteSettings(name: '/add/location'),
                  ),
                );
              },
              child: Container(
                child: Text(
                  "Add Location",
                  style: TextStyle(color: CustomColors.buyerBlack),
                ),
              ),
            );
          } else {
            child = InkWell(
              onTap: () async {
                double _distanceInMeters = await Geolocator().distanceBetween(
                  10.393141525631743,
                  77.83373191952705,
                  10.393141525631743,
                  77.83373191952705,
                );
                print("Distance: " + _distanceInMeters.toString());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLocation(),
                    settings: RouteSettings(name: '/add/location'),
                  ),
                );
              },
              child: Container(
                child: Row(
                  children: [
                    Text(
                      "${snapshot.data.first.locationName}",
                      style: TextStyle(color: CustomColors.buyerBlack),
                    ),
                    NearByStores(snapshot.data.first),
                  ],
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Container(
            child: Row(
              children: [
                Text("Error..."),
              ],
            ),
          );
        } else {
          child = Container(
            child: Row(
              children: [
                Text("Loading..."),
              ],
            ),
          );
        }

        return child;
      },
    );
  }

  Widget getCategoryCards(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      primary: true,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Groceries click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Groceries")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Fruits & Vegetables");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Fruits & Vegetables")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Fish & Meat click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Fish & Meat")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Super Markets click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Super Markets")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Groceries click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Groceries")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Fruits & Vegetables");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Fruits & Vegetables")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Fish & Meat click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Fish & Meat")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      print("Super Markets click");
                    },
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        width: 100,
                        height: 75,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.local_grocery_store),
                            Text("Super Markets")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getOrdersCard(context) {
    return FutureBuilder(
      future: cachedLocalUser.getLocations(),
      builder: (context, AsyncSnapshot<List<UserLocations>> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.length == 0) {
            child = InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLocation(),
                    settings: RouteSettings(name: '/add/location'),
                  ),
                );
              },
              child: Container(
                child: Text(
                  "Add Location",
                  style: TextStyle(color: CustomColors.buyerBlack),
                ),
              ),
            );
          } else {
            child = InkWell(
              onTap: () {
                print("Location click");
              },
              child: Container(
                child: Row(
                  children: [
                    Text("${snapshot.data.first.locationName}"),
                  ],
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Container(
            child: Row(
              children: [
                Text("Error..."),
              ],
            ),
          );
        } else {
          child = Container(
            child: Row(
              children: [
                Text("Loading..."),
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/user/NearByStores.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

import '../../db/models/store.dart';
import '../../services/controllers/user/user_service.dart';
import '../../services/controllers/user/user_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      backgroundColor: CustomColors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomColors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(Icons.location_on,
                              size: 20, color: CustomColors.positiveGreen),
                        ),
                        getLocation(),
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
                        color: CustomColors.grey,
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
                    "Top Stores",
                    style: TextStyle(
                        fontFamily: "Georgia",
                        color: CustomColors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: getFavStores(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getLocation() {
    return cachedLocalUser.primaryLocation == null
        ? InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                  settings: RouteSettings(name: '/add/location'),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                child: Text(
                  "Add Location",
                  style: TextStyle(color: CustomColors.black),
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                  settings: RouteSettings(name: '/add/location'),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                child: Text(
                  "${cachedLocalUser.primaryLocation.locationName}",
                  style: TextStyle(color: CustomColors.black),
                ),
                // NearByStores(snapshot.data.first),
              ),
            ),
          );
  }

  Widget getFavStores(BuildContext context) {
    return FutureBuilder(
        future: Store().streamFavStores(cachedLocalUser.primaryLocation),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              child = Container(
                child: Text(
                  "No stores",
                  style: TextStyle(color: CustomColors.black),
                ),
              );
            } else {
              child = Container(
                height: (snapshot.data.length * 120).toDouble(),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Store store = snapshot.data[index];

                    return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Container(
                        child: FittedBox(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewStoreScreen(store),
                                  settings: RouteSettings(name: '/store'),
                                ),
                              );
                            },
                            child: Material(
                              color: CustomColors.white,
                              elevation: 10.0,
                              borderRadius: BorderRadius.circular(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            store.getMediumProfilePicPath(),
                                        imageBuilder:
                                            (context, imageProvider) => Image(
                                          fit: BoxFit.fill,
                                          image: imageProvider,
                                        ),
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          size: 35,
                                        ),
                                        fadeOutDuration: Duration(seconds: 1),
                                        fadeInDuration: Duration(seconds: 2),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Container(
                                                  child: Text(
                                                store.storeName,
                                                style: TextStyle(
                                                    color: CustomColors.blue,
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                            ),
                                            SizedBox(height: 5.0),
                                            Container(
                                                child: Text(
                                              "Timings - ${store.activeFrom} : ${store.activeTill}",
                                              style: TextStyle(
                                                color: CustomColors.black,
                                                fontSize: 16.0,
                                              ),
                                            )),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Container(
              child: Text(
                "Error...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          } else {
            child = Container(
              child: Text(
                "Loading...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          }
          return child;
        });
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
                  style: TextStyle(color: CustomColors.black),
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

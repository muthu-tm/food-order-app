import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      backgroundColor: CustomColors.buyerWhite,
      body: SingleChildScrollView(
        child: Container(
          color: CustomColors.buyerLightGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.location_on,
                          size: 30, color: CustomColors.buyerPositiveGreen)),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: getLocation(),
                  ),
                ],
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
            child = Container(
              child: FlatButton.icon(
                onPressed: () {
                  print("Location Add");
                },
                icon: Icon(Icons.location_searching, size: 25),
                label: Text("Add Location"),
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
                    Icon(Icons.arrow_drop_down, size: 25),
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
                Icon(Icons.arrow_drop_down, size: 25),
              ],
            ),
          );
        } else {
          child = Container(
            child: Row(
              children: [
                Text("Loading..."),
                Icon(Icons.arrow_drop_down, size: 25),
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}

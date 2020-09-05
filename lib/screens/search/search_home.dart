import 'package:chipchop_buyer/db/models/store_locations.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/search/stores_in_map.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchHome extends StatefulWidget {
  @override
  _SearchHomeState createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> {
  UserLocations locations;
  Stream<List<DocumentSnapshot>> stores;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SearchBarWidget(
          performSearch: null,
        ),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "or",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            RaisedButton(
              color: CustomColors.mfinBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: CustomColors.mfinButtonGreen)),
              onPressed: () {
                getUserLocation();
                getNearBuyStores();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoresInMap(stores, locations),
                    settings: RouteSettings(name: '/settings/user/edit'),
                  ),
                );
              },
              child: Text(
                "Nearby stores in map",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  void getUserLocation() async {
    List<UserLocations> userLocations = await cachedLocalUser.getLocations();
    locations = userLocations.first;
  }

  void getNearBuyStores() async {
    stores = StoreLocations().streamNearByStores(locations);
  }
}

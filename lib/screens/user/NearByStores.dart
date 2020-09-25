import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NearByStores extends StatelessWidget {
  NearByStores(this.loc);

  final UserLocations loc;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Store().streamNearByStores(loc, 5),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
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
            Store store =
                Store.fromJson(snapshot.data[0].data);
            child = Container(
              child: Text(
                "${store.name}",
                style: TextStyle(color: CustomColors.black),
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
      },
    );
  }
}

import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/store/StoreWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ListOfTopCategoryStores extends StatelessWidget {
  final String typeID;
  final String categoryName;
  ListOfTopCategoryStores(this.typeID, this.categoryName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      backgroundColor: CustomColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "Top $categoryName stores",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            getListOfStores()
          ],
        ),
      ),
    );
  }

  Widget getListOfStores() {
    return FutureBuilder(
      future: Store().getStoresByTypes(typeID),
      builder: (context, AsyncSnapshot<List<Store>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            child = Container(
              child: Center(
                child: Text(
                  "No stores Found",
                  style: TextStyle(color: CustomColors.black),
                ),
              ),
            );
          } else {
            child = ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Store store = snapshot.data[index];

                return StoreWidget(store);
              },
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

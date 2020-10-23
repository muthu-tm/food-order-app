import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ListOfTopCategoryStores extends StatelessWidget {
  final String typeID;
  final String categoryName;
  ListOfTopCategoryStores(this.typeID, this.categoryName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$categoryName stores",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart, color: CustomColors.black),
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
      ),
      backgroundColor: CustomColors.white,
      body: SingleChildScrollView(child: getListOfStores()),
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
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

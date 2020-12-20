import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ListOfTopCategoryStores extends StatelessWidget {
  final Map<String, String> id;
  final String fieldName;
  final String categoryName;

  ListOfTopCategoryStores(this.id, this.fieldName, this.categoryName);

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
          "$categoryName",
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            title: Text(
              "Listed $categoryName shops near you",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          getListOfStores(),
        ],
      )),
    );
  }

  Widget getListOfStores() {
    return FutureBuilder(
      future: Store().getStoresByTypes(fieldName, id),
      builder: (context, AsyncSnapshot<List<Store>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            child = Container(
              height: 200,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sorry, No Stores Found !! ",
                    style: TextStyle(color: CustomColors.black),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.sentiment_dissatisfied)
                ],
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

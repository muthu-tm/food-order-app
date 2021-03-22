import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/orders/EmptyCartWidget.dart';
import 'package:chipchop_buyer/screens/orders/StoreCartItems.dart';
import 'package:chipchop_buyer/screens/orders/StoreWishlistItems.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../utils/CustomColors.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  final format = DateFormat('dd MMM, yyyy h:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "My Cart",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              getBody(context),
              getWishlistItems(context),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamCartItems(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
            child = Padding(
              padding: EdgeInsets.all(5.0),
              child: EmptyCartWidget(),
            );
          } else {
            Map<String, List<ShoppingCart>> cartItems = {};
            Map<String, String> cartStores = {};

            snapshot.data.docs.forEach((element) {
              ShoppingCart _sc = ShoppingCart.fromJson(element.data());
              cartItems.update(_sc.storeID, (value) {
                value.add(_sc);
                return value;
              }, ifAbsent: () => [_sc]);

              cartStores.putIfAbsent(_sc.storeID, () => _sc.storeName);
            });

            child = SingleChildScrollView(
              child: Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: cartStores.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(
                    color: CustomColors.black,
                    height: 0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    String storeID = cartStores.entries.elementAt(index).key;
                    String storeName =
                        cartStores.entries.elementAt(index).value;
                    return StoreCartItems(
                        storeID, storeName, cartItems[storeID]);
                  },
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
        return child;
      },
    );
  }

  Widget getWishlistItems(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamWishlist(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
            child = Container();
          } else {
            Map<String, List<ShoppingCart>> wlItems = {};
            Map<String, String> wlStores = {};

            snapshot.data.docs.forEach((element) {
              ShoppingCart _sc = ShoppingCart.fromJson(element.data());
              wlItems.update(_sc.storeID, (value) {
                value.add(_sc);
                return value;
              }, ifAbsent: () => [_sc]);

              wlStores.putIfAbsent(_sc.storeID, () => _sc.storeName);
            });

            child = SingleChildScrollView(
              child: Card(
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[400]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Text(
                          "My Wishlist",
                          style: TextStyle(
                              color: CustomColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: ListView.separated(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: wlStores.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                            color: CustomColors.black,
                            height: 0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            String storeID =
                                wlStores.entries.elementAt(index).key;
                            return StoreWishlistItems(
                                storeID, wlItems[storeID]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
        return child;
      },
    );
  }
}

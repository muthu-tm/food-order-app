import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/CustomColors.dart';

class CartCounter extends StatefulWidget {
  CartCounter(this.storeID, this.storeName, this.productID);

  final String storeID;
  final String storeName;
  final String productID;
  @override
  _CartCounterState createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ShoppingCart()
            .streamCartForProduct(widget.storeID, widget.productID),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.documents.isEmpty) {
              child = Card(
                elevation: 2.0,
                color: CustomColors.green,
                child: Container(
                  height: 40,
                  width: 40,
                  child: IconButton(
                    iconSize: 20,
                    alignment: Alignment.center,
                    icon: Icon(
                      FontAwesomeIcons.cartPlus,
                      color: CustomColors.black,
                    ),
                    onPressed: () async {
                      try {
                        CustomDialogs.showLoadingDialog(context, _keyLoader);
                        ShoppingCart sc = ShoppingCart();
                        sc.storeName = widget.storeName;
                        sc.storeID = widget.storeID;
                        sc.productID = widget.productID;
                        sc.inWishlist = false;
                        sc.quantity = 1.0;
                        await sc.create();
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();
                      } catch (err) {
                        print(err);
                      }
                    },
                  ),
                ),
              );
            } else {
              ShoppingCart sc =
                  ShoppingCart.fromJson(snapshot.data.documents.first.data);
              child = Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    sc.quantity == 1.0
                        ? SizedBox(
                            width: 35,
                            height: 35,
                            child: OutlineButton(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onPressed: () async {
                                try {
                                  CustomDialogs.showLoadingDialog(
                                      context, _keyLoader);
                                  await ShoppingCart().removeItem(
                                      false, widget.storeID, widget.productID);
                                  Navigator.of(_keyLoader.currentContext,
                                          rootNavigator: true)
                                      .pop();
                                } catch (err) {
                                  print(err);
                                }
                              },
                              child: Icon(
                                Icons.delete_forever,
                                size: 20,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 35,
                            height: 35,
                            child: OutlineButton(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onPressed: () async {
                                try {
                                  CustomDialogs.showLoadingDialog(
                                      context, _keyLoader);
                                  await ShoppingCart().updateCartQuantity(
                                      false, widget.storeID, widget.productID);
                                  Navigator.of(_keyLoader.currentContext,
                                          rootNavigator: true)
                                      .pop();
                                } catch (err) {
                                  print(err);
                                }
                              },
                              child: Icon(Icons.remove),
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        sc.quantity.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Georgia',
                            color: CustomColors.blue,
                            fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: OutlineButton(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onPressed: () async {
                          try {
                            CustomDialogs.showLoadingDialog(
                                context, _keyLoader);
                            await ShoppingCart().updateCartQuantity(
                                true, widget.storeID, widget.productID);
                            Navigator.of(_keyLoader.currentContext,
                                    rootNavigator: true)
                                .pop();
                          } catch (err) {
                            print(err);
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
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
        });
  }
}

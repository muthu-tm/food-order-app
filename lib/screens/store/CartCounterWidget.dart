import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/CustomColors.dart';

class CartCounter extends StatefulWidget {
  CartCounter(this.storeID, this.storeName, this.productID, this.productName,
      this.variantID);

  final String storeID;
  final String storeName;
  final String productID;
  final String productName;
  final String variantID;
  @override
  _CartCounterState createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            ShoppingCart().streamForProduct(widget.storeID, widget.productID),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.documents.isEmpty) {
              child = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: Colors.greenAccent[100],
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          CustomDialogs.actionWaiting(context);
                          ShoppingCart wl = ShoppingCart();
                          wl.storeName = widget.storeName;
                          wl.storeID = widget.storeID;
                          wl.productID = widget.productID;
                          wl.productName = widget.productName;
                          wl.inWishlist = false;
                          wl.variantID = widget.variantID;
                          wl.quantity = 1.0;
                          await wl.create();
                          Navigator.pop(context);
                        } catch (err) {
                          print(err);
                        }
                      },
                      child: Container(
                        height: 30,
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20, color: Colors.green),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                "ADD",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          CustomDialogs.actionWaiting(context);
                          ShoppingCart wl = ShoppingCart();
                          wl.storeName = widget.storeName;
                          wl.storeID = widget.storeID;
                          wl.productID = widget.productID;
                          wl.variantID = widget.variantID;
                          wl.inWishlist = true;
                          wl.quantity = 1.0;
                          await wl.create();
                          Navigator.pop(context);
                        } catch (err) {
                          print(err);
                        }
                      },
                      child: Container(
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(Icons.favorite_border, color: Colors.red),
                      ),
                    ),
                  )
                ],
              );
            } else {
              bool isWishlist = false;
              double quantity = 0;
              snapshot.data.documents.forEach((element) {
                ShoppingCart sc = ShoppingCart.fromJson(element.data);

                if (sc.variantID == widget.variantID) {
                  if (sc.inWishlist) {
                    isWishlist = true;
                  } else {
                    quantity = sc.quantity;
                  }
                }
              });
              child = Row(
                children: [
                  quantity > 0
                      ? Container(
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue[100]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              quantity == 1.0
                                  ? InkWell(
                                      onTap: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart().removeItem(
                                              false,
                                              widget.storeID,
                                              widget.productID,
                                              widget.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: Icon(Icons.delete_forever),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart()
                                              .updateCartQuantity(
                                                  false,
                                                  widget.storeID,
                                                  widget.productID,
                                                  widget.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: Icon(Icons.remove),
                                      ),
                                    ),
                              Padding(
                                padding:
                                    EdgeInsets.only(right: 10.0, left: 10.0),
                                child: Text(
                                  quantity.round().toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CustomColors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  try {
                                    CustomDialogs.showLoadingDialog(
                                        context, _keyLoader);
                                    await ShoppingCart().updateCartQuantity(
                                        true,
                                        widget.storeID,
                                        widget.productID,
                                        widget.variantID);
                                    Navigator.of(_keyLoader.currentContext,
                                            rootNavigator: true)
                                        .pop();
                                  } catch (err) {
                                    print(err);
                                  }
                                },
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Card(
                          color: Colors.greenAccent[100],
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: InkWell(
                            onTap: () async {
                              try {
                                CustomDialogs.actionWaiting(context);
                                ShoppingCart wl = ShoppingCart();
                                wl.storeName = widget.storeName;
                                wl.storeID = widget.storeID;
                                wl.productID = widget.productID;
                                wl.productName = widget.productName;
                                wl.variantID = widget.variantID;
                                wl.inWishlist = false;
                                wl.quantity = 1.0;
                                await wl.create();
                                Navigator.pop(context);
                              } catch (err) {
                                print(err);
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      size: 20, color: Colors.green),
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      "ADD",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: 5,
                  ),
                  !isWishlist
                      ? Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: InkWell(
                            onTap: () async {
                              try {
                                CustomDialogs.actionWaiting(context);
                                ShoppingCart wl = ShoppingCart();
                                wl.storeName = widget.storeName;
                                wl.storeID = widget.storeID;
                                wl.productID = widget.productID;
                                wl.variantID = widget.variantID;
                                wl.inWishlist = true;
                                wl.quantity = 1.0;
                                await wl.create();
                                Navigator.pop(context);
                              } catch (err) {
                                print(err);
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Icon(Icons.favorite_border,
                                  color: Colors.red),
                            ),
                          ),
                        )
                      : Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            height: 30,
                            width: 60,
                            child: InkWell(
                              onTap: () async {
                                try {
                                  CustomDialogs.actionWaiting(context);
                                  await ShoppingCart().removeItem(
                                      true,
                                      widget.storeID,
                                      widget.productID,
                                      widget.variantID);
                                  Navigator.pop(context);
                                } catch (err) {
                                  print(err);
                                }
                              },
                              child: Icon(Icons.favorite, color: Colors.red),
                            ),
                          ),
                        )
                ],
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

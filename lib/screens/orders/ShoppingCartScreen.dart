import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/orders/EmptyCartWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int shoppingCartCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamCartItems(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            child = Padding(
              padding: EdgeInsets.all(5.0),
              child: EmptyCartWidget(),
            );
          } else {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      ShoppingCart _sc = ShoppingCart.fromJson(
                          snapshot.data.documents[index].data);

                      return buildShoppingCartItem(context, _sc);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  height: 120,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Subtotal",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$278.78",
                                style: TextStyle(color: CustomColors.black),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Shipping cost",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$20.00",
                                style: TextStyle(
                                    color: CustomColors.black, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Total",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$308.78",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, left: 8.0, right: 8.0, bottom: 16.0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    color: Colors.blueGrey,
                    onPressed: () => {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Checkout",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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

  Widget buildShoppingCartItem(BuildContext context, ShoppingCart sc) {
    return FutureBuilder<Products>(
      future: Products().getByProductID(sc.productID),
      builder: (context, AsyncSnapshot<Products> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          Products _p = snapshot.data;
          child = Card(
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        width: 125,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 125,
                              height: 125,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: _p.getProductImage(),
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    fit: BoxFit.fill,
                                    image: imageProvider,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          valueColor: AlwaysStoppedAnimation(
                                              CustomColors.blue),
                                          strokeWidth: 2.0),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 35,
                                  ),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width - 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${_p.name}',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Weight: ',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: CustomColors.positiveGreen,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '${_p.weight}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: CustomColors.black),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    _p.getUnit(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CustomColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FlatButton(
                                  child: Text(
                                    "Show Details",
                                    style: TextStyle(color: CustomColors.blue),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(_p),
                                        settings: RouteSettings(
                                            name: '/store/products'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
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
                                      child: Icon(Icons.delete_forever),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.actionWaiting(context);
                                          await ShoppingCart().removeItem(
                                              false, sc.storeID, sc.productID);
                                          Navigator.pop(context);
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
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
                                      child: Icon(Icons.remove),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.actionWaiting(context);
                                          await ShoppingCart()
                                              .updateCartQuantityByID(
                                                  false, sc.uuid);
                                          Navigator.pop(context);
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 10.0),
                              child: Text(
                                sc.quantity.round().toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: CustomColors.blue,
                                    fontWeight: FontWeight.bold),
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
                                child: Icon(Icons.add),
                                onPressed: () async {
                                  try {
                                    CustomDialogs.actionWaiting(context);
                                    await ShoppingCart()
                                        .updateCartQuantityByID(true, sc.uuid);
                                    Navigator.pop(context);
                                  } catch (err) {
                                    print(err);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Rs. ${_p.currentPrice}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
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

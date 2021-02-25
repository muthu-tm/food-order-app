import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/orders/StoreCartItems.dart';
import 'package:chipchop_buyer/screens/orders/StoreWishlistItems.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/CustomColors.dart';

class StoreOrderScreen extends StatefulWidget {
  StoreOrderScreen(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _StoreOrderScreenState createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends State<StoreOrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<String> imagePaths = [];
  String writtenOrders = "";
  bool textBoxEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Order - ${widget.storeName}",
          overflow: TextOverflow.ellipsis,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget getWishlistItems(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamWishlistForStore(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
            child = Container();
          } else {
            List<ShoppingCart> _sc = [];

            snapshot.data.docs.forEach((element) {
              _sc.add(
                ShoppingCart.fromJson(
                  element.data(),
                ),
              );
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
                      Container(child: StoreWishlistItems(widget.storeID, _sc))
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

  Widget buildingWishListItem(BuildContext context, ShoppingCart sc) {
    return FutureBuilder<Products>(
      future: Products().getByProductID(sc.productID),
      builder: (BuildContext context, AsyncSnapshot<Products> snapshot) {
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
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(_p),
                                settings:
                                    RouteSettings(name: '/store/products'),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${_p.name}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
                                          color: CustomColors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${_p.variants[int.parse(sc.variantID)].weight}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CustomColors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      _p.variants[int.parse(sc.variantID)]
                                          .getUnit(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Price: ',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: CustomColors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                                        '₹ ${_p.variants[int.parse(sc.variantID)].currentPrice.toStringAsFixed(2)}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: CustomColors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: RaisedButton(
                                      color: CustomColors.lightGrey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(color: Colors.red)),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart().removeItem(
                                              true,
                                              sc.storeID,
                                              sc.productID,
                                              sc.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: CustomColors.alertRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: RaisedButton(
                                      color: CustomColors.lightGrey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side:
                                              BorderSide(color: Colors.green)),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          bool res = await ShoppingCart()
                                              .moveToCart(sc.uuid, sc.storeID,
                                                  sc.productID, sc.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                          if (!res)
                                            Fluttertoast.showToast(
                                                msg:
                                                    'This Product already in Your Cart !');
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: Text(
                                        "Move to cart",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          child = Center(
            child: Container(
              height: 100,
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          child = Center(
            child: Container(
              height: 100,
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

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamCartsForStore(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          List<ShoppingCart> cartItems = [];

          snapshot.data.docs.forEach((element) {
            ShoppingCart _sc = ShoppingCart.fromJson(element.data());
            cartItems.add(_sc);
          });

          child = SingleChildScrollView(
            child: StoreCartItems(widget.storeID, widget.storeName, cartItems),
          );
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

  Widget buildShoppingCartItem(BuildContext context, ShoppingCart sc) {
    return FutureBuilder<Products>(
      future: Products().getByProductID(sc.productID),
      builder: (BuildContext context, AsyncSnapshot<Products> snapshot) {
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
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(_p),
                          settings: RouteSettings(name: '/store/products'),
                        ),
                      );
                    },
                    child: Row(
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
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
                                      'Weight : ',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: CustomColors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${_p.variants[int.parse(sc.variantID)].weight}',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CustomColors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      _p.variants[int.parse(sc.variantID)]
                                          .getUnit(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Price : ',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: CustomColors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                                        '₹ ${_p.variants[int.parse(sc.variantID)].currentPrice.toStringAsFixed(2)}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: CustomColors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: <Widget>[
                                        sc.quantity == 1.0
                                            ? SizedBox(
                                                width: 35,
                                                height: 35,
                                                child: OutlineButton(
                                                  padding: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Icon(
                                                      Icons.delete_forever),
                                                  onPressed: () async {
                                                    try {
                                                      CustomDialogs
                                                          .showLoadingDialog(
                                                              context,
                                                              _keyLoader);
                                                      await ShoppingCart()
                                                          .removeItem(
                                                              false,
                                                              sc.storeID,
                                                              sc.productID,
                                                              sc.variantID);
                                                      Navigator.of(
                                                              _keyLoader
                                                                  .currentContext,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Icon(Icons.remove),
                                                  onPressed: () async {
                                                    try {
                                                      CustomDialogs
                                                          .showLoadingDialog(
                                                              context,
                                                              _keyLoader);
                                                      await ShoppingCart()
                                                          .updateCartQuantityByID(
                                                              false, sc.uuid);
                                                      Navigator.of(
                                                              _keyLoader
                                                                  .currentContext,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    } catch (err) {
                                                      print(err);
                                                    }
                                                  },
                                                ),
                                              ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 10.0, left: 10.0),
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Icon(Icons.add),
                                            onPressed: () async {
                                              try {
                                                CustomDialogs.showLoadingDialog(
                                                    context, _keyLoader);
                                                await ShoppingCart()
                                                    .updateCartQuantityByID(
                                                        true, sc.uuid);
                                                Navigator.of(
                                                        _keyLoader
                                                            .currentContext,
                                                        rootNavigator: true)
                                                    .pop();
                                              } catch (err) {
                                                print(err);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        '₹ ${_p.variants[int.parse(sc.variantID)].currentPrice * sc.quantity}',
                                        maxLines: 2,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.red)),
                            onPressed: () async {
                              try {
                                CustomDialogs.showLoadingDialog(
                                    context, _keyLoader);
                                await ShoppingCart().removeItem(false,
                                    sc.storeID, sc.productID, sc.variantID);
                                Navigator.of(_keyLoader.currentContext,
                                        rootNavigator: true)
                                    .pop();
                              } catch (err) {
                                print(err);
                              }
                            },
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 12,
                                color: CustomColors.alertRed,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: RaisedButton(
                            color: CustomColors.lightGrey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.green)),
                            onPressed: () async {
                              try {
                                CustomDialogs.showLoadingDialog(
                                    context, _keyLoader);
                                bool res = await ShoppingCart().moveToWishlist(
                                    sc.uuid,
                                    sc.storeID,
                                    sc.productID,
                                    sc.variantID);
                                Navigator.of(_keyLoader.currentContext,
                                        rootNavigator: true)
                                    .pop();

                                if (!res)
                                  Fluttertoast.showToast(
                                      msg:
                                          'This Product already in Your WishList !');
                              } catch (err) {
                                print(err);
                              }
                            },
                            child: Text(
                              "Move To Wishlist",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
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
          child = Center(
            child: Container(
              height: 100,
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          child = Center(
            child: Container(
              height: 100,
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

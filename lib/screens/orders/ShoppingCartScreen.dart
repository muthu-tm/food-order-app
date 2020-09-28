import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/orders/EmptyCartWidget.dart';
import 'package:chipchop_buyer/screens/orders/OrderSuccessWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
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

  checkoutBottomSheet(BuildContext context, List<double> _priceDetails) {
    return _scaffoldKey.currentState.showBottomSheet((context) {
      return Builder(builder: (BuildContext childContext) {
        return Container(
          height: 450,
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: ListView(
                    primary: false,
                    children: <Widget>[
                      selectedAddressSection(),
                      priceSection(_priceDetails)
                    ],
                  ),
                ),
                flex: 85,
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(childContext);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomColors.alertRed,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          height: 40,
                          width: 50,
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 30, color: CustomColors.white),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          try {
                            Navigator.pop(childContext);
                            CustomDialogs.actionWaiting(context);
                            Order _o = Order();
                            OrderAmount _oa = OrderAmount();
                            OrderDelivery _od = OrderDelivery();

                            _oa.deliveryCharge = _priceDetails[2];
                            _oa.offerAmount = 0.00;
                            _oa.orderAmount = _priceDetails[0];
                            _o.amount = _oa;

                            _od.address =
                                cachedLocalUser.primaryLocation.address;
                            _od.geoPoint =
                                cachedLocalUser.primaryLocation.geoPoint;
                            _o.delivery = _od;

                            _o.customerNotes = "";
                            _o.isReturnable = false;
                            _o.status = 0;
                            _o.userNumber =
                                cachedLocalUser.primaryLocation.userNumber;
                            _o.storeID = "";
                            _o.totalProducts = 1;
                            _o.writtenOrders = "";
                            _o.orderImages = [""];
                            _o.isReturnable = false;

                            await _o.create();
                            // Navigator.pop(context);
                            await showDialog(
                              context: context,
                              child: OrderSuccessWidget(),
                            );
                          } catch (err) {
                            print(err);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomColors.blue,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          height: 40,
                          width: MediaQuery.of(context).size.width - 150,
                          child: Center(
                            child: Text(
                              "Place Order",
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 15,
              )
            ],
          ),
        );
      });
    },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        elevation: 5);
  }

  selectedAddressSection() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    cachedLocalUser.firstName + " " + cachedLocalUser.lastName,
                    style: TextStyle(
                        fontFamily: "Georgia",
                        color: CustomColors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Text(
                      cachedLocalUser.primaryLocation.locationName,
                      style: TextStyle(color: CustomColors.blue, fontSize: 10),
                    ),
                  )
                ],
              ),
              createAddressText(
                  cachedLocalUser.primaryLocation.address.street, 16),
              createAddressText(
                  cachedLocalUser.primaryLocation.address.city, 6),
              createAddressText(
                  cachedLocalUser.primaryLocation.address.pincode, 6),
              SizedBox(
                height: 6,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Mobile : ",
                      style: TextStyle(fontSize: 12, color: CustomColors.blue),
                    ),
                    TextSpan(
                      text: cachedLocalUser.mobileNumber.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.grey.shade300,
                height: 1,
                width: double.infinity,
              ),
              addressAction()
            ],
          ),
        ),
      ),
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  addressAction() {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(
            flex: 2,
          ),
          FlatButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                  settings: RouteSettings(name: '/location'),
                ),
              );
            },
            child: Text(
              "Edit / Change",
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 3,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          Spacer(
            flex: 3,
          ),
          FlatButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                  settings: RouteSettings(name: '/location/add'),
                ),
              );
            },
            child: Text("Add New Address",
                style: TextStyle(fontSize: 12, color: Colors.indigo.shade700)),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  priceSection(List<double> priceDetails) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Text(
                "PRICE DETAILS",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              createPriceItem("Order Total", '₹ ' + priceDetails[0].toString(),
                  CustomColors.black),
              createPriceItem("Your Savings", '₹ ' + priceDetails[1].toString(),
                  CustomColors.green),
              createPriceItem("Delievery Charges",
                  '₹ ' + priceDetails[2].toString(), CustomColors.black),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    "₹ ${priceDetails[0] + priceDetails[2]}",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  createPriceItem(String key, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12),
          )
        ],
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
                    primary: false,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      ShoppingCart _sc = ShoppingCart.fromJson(
                          snapshot.data.documents[index].data);

                      if (index == snapshot.data.documents.length - 1) {
                        return buildShoppingCartItem(context, _sc);
                      } else {
                        return buildShoppingCartItem(context, _sc);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: CustomColors.blue,
                    onPressed: () async {
                      if (snapshot.data.documents.isEmpty) {
                        return;
                      }
                      CustomDialogs.actionWaiting(context);

                      double cPrice = 0.00;
                      double oPrice = 0.00;
                      for (var item in snapshot.data.documents) {
                        ShoppingCart _sc = ShoppingCart.fromJson(item.data);
                        Products p =
                            await Products().getByProductID(_sc.productID);
                        cPrice += _sc.quantity * p.currentPrice;
                        oPrice += _sc.quantity * p.offer;
                      }

                      double sCharge = await Store().getShippingCharge(
                          snapshot.data.documents.first.data['store_uuid']);

                      List<double> _priceDetails = [cPrice, oPrice, sCharge];
                      Navigator.pop(context);
                      checkoutBottomSheet(context, _priceDetails);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      child: Text(
                        "Checkout",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Georgia",
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
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
      },
    );
  }

  Widget buildShoppingCartItem(BuildContext context, ShoppingCart sc) {
    return FutureBuilder<Products>(
      future: Products().getByProductID(sc.productID),
      builder: (context, AsyncSnapshot<Products> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          isLoading = false;

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
                                        fontFamily: "Georgia",
                                        color: CustomColors.lightBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '${_p.weight}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: CustomColors.black,
                                    fontFamily: "Georgia",
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    _p.getUnit(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "Georgia",
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
                                        fontFamily: "Georgia",
                                        color: CustomColors.lightBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Rs. ${_p.currentPrice}',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontFamily: "Georgia",
                                        fontSize: 16,
                                        color: CustomColors.black,
                                      ),
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
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: RaisedButton(
                              color: CustomColors.lightGrey,
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
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CustomColors.alertRed,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                              'Rs. ${_p.currentPrice * sc.quantity}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: "Georgia",
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

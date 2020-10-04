import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/orders/OrderAmountWidget.dart';
import 'package:chipchop_buyer/screens/orders/OrderChatScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../db/models/order.dart';
import '../../services/utils/DateUtils.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen(this.orderID);

  final String orderID;
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Order Details",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {
          return _scaffoldKey.currentState.showBottomSheet((context) {
            return Builder(builder: (BuildContext childContext) {
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: CustomColors.lightGrey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: OrderChatScreen(
                    orderUUID: widget.orderID,
                  ),
                ),
              );
            });
          });
        },
        label: Text("Chat"),
        icon: Icon(Icons.chat),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: getBody(context),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: Order().streamOrderByID(widget.orderID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          Order order = Order.fromJson(snapshot.data.data);

          child = Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    order.orderID,
                    style: TextStyle(
                        color: CustomColors.purple,
                        fontSize: 14,
                        fontFamily: "Georgia"),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_basket,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Status"),
                trailing: Text(
                  order.getStatus(),
                  style: TextStyle(
                      color: CustomColors.purple,
                      fontSize: 18,
                      fontFamily: "Georgia"),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Ordered At"),
                trailing: Text(
                  DateUtils.formatDateTime(order.createdAt),
                  style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 14,
                      fontFamily: "Georgia"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  color: CustomColors.grey,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.local_shipping,
                          size: 35,
                          color: CustomColors.blueGreen,
                        ),
                        title: Text(
                          "Delivery Address",
                        ),
                        trailing: Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: CustomColors.lightPurple.withOpacity(0.5),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Text(
                            order.delivery.userLocation.locationName,
                            style: TextStyle(
                                color: CustomColors.black,
                                fontSize: 12,
                                fontFamily: "Georgia"),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Text(""),
                        title: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: EdgeInsets.only(right: 10, left: 10),
                          decoration: BoxDecoration(
                            color: CustomColors.lightGrey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              createAddressText(
                                  order.delivery.userLocation.address.street,
                                  16),
                              createAddressText(
                                  order.delivery.userLocation.address.city, 6),
                              createAddressText(
                                  order.delivery.userLocation.address.pincode,
                                  6),
                              SizedBox(
                                height: 6,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Mobile : ",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: CustomColors.blue),
                                    ),
                                    TextSpan(
                                      text: order
                                          .delivery.userLocation.userNumber,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.shippingFast,
                          color: CustomColors.blueGreen,
                        ),
                        title: TextFormField(
                          initialValue: order.delivery.expectedAt == null
                              ? ""
                              : DateUtils.formatDateTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      order.delivery.expectedAt),
                                ),
                          textAlign: TextAlign.start,
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.lightGreen),
                            ),
                            labelText: "Expected Delivery Time",
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: CustomColors.blue,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.phone_android,
                          size: 35,
                          color: CustomColors.blueGreen,
                        ),
                        title: TextFormField(
                          initialValue: order.delivery.deliveryContact ?? "",
                          textAlign: TextAlign.start,
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.lightGreen),
                            ),
                            labelText: "Delivery - Contact Numer",
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: CustomColors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OrderAmountWidget(order),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.shoppingBasket,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Products"),
              ),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: order.products.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder(
                      future: Products()
                          .getByProductID(order.products[index].productID),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      width: 125,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            width: 125,
                                            height: 125,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: _p.getProductImage(),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Image(
                                                  fit: BoxFit.fill,
                                                  image: imageProvider,
                                                ),
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child: SizedBox(
                                                    height: 50.0,
                                                    width: 50.0,
                                                    child: CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                                CustomColors
                                                                    .blue),
                                                        strokeWidth: 2.0),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  size: 35,
                                                ),
                                                fadeOutDuration:
                                                    Duration(seconds: 1),
                                                fadeInDuration:
                                                    Duration(seconds: 2),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      width: MediaQuery.of(context).size.width -
                                          150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Weight: ',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily: "Georgia",
                                                      color: CustomColors
                                                          .lightBlue,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: "Georgia",
                                                    color: CustomColors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Price: ',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily: "Georgia",
                                                      color: CustomColors
                                                          .lightBlue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
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
                                                  style: TextStyle(
                                                      color: CustomColors.blue),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetailsScreen(
                                                              _p),
                                                      settings: RouteSettings(
                                                          name:
                                                              '/store/products'),
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
                                ListTile(
                                  leading: Text(
                                    "Quantity: ",
                                    style: TextStyle(
                                        fontFamily: "Georgia",
                                        fontSize: 16,
                                        color: CustomColors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  title: Text(
                                    '${order.products[index].quantity.round()}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: "Georgia",
                                        fontSize: 16,
                                        color: CustomColors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    'Rs. ${order.products[index].amount}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: "Georgia",
                                        fontSize: 16,
                                        color: CustomColors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                order.status <= 1
                                    ? RaisedButton.icon(
                                        color: CustomColors.alertRed,
                                        onPressed: () async {
                                          try {
                                            await order.cancelOrder(
                                                order.uuid, "");
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Order Cancelled Successfully',
                                                backgroundColor:
                                                    CustomColors.grey,
                                                textColor: CustomColors.white);
                                          } catch (err) {
                                            print(err);
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Error, Unable to Cancel Order',
                                                backgroundColor:
                                                    CustomColors.alertRed,
                                                textColor: CustomColors.white);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: CustomColors.lightGrey,
                                        ),
                                        label: Text(
                                          "Cancel Order",
                                          style: TextStyle(
                                              color: CustomColors.lightGrey,
                                              fontSize: 14),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ));
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
                  },
                ),
              )
            ],
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

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }
}

import 'package:chipchop_buyer/screens/orders/OrderChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
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
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
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
                          order.delivery.userLocation.address.street, 16),
                      createAddressText(
                          order.delivery.userLocation.address.city, 6),
                      createAddressText(
                          order.delivery.userLocation.address.pincode, 6),
                      SizedBox(
                        height: 6,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Mobile : ",
                              style: TextStyle(
                                  fontSize: 12, color: CustomColors.blue),
                            ),
                            TextSpan(
                              text: order.delivery.userLocation.userNumber,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
import '../../services/utils/DateUtils.dart';
import '../app/appBar.dart';
import '../app/bottomBar.dart';
import '../app/sideDrawer.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';
import '../utils/CustomColors.dart';

class OrdersHomeScreen extends StatefulWidget {
  @override
  _OrdersHomeScreenState createState() => _OrdersHomeScreenState();
}

class _OrdersHomeScreenState extends State<OrdersHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: getBody(context),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: Order().streamOrders(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            child = Container(
              child: Center(
                // alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_neutral,
                      size: 40,
                      color: CustomColors.purple,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No Orders Found!",
                      style: TextStyle(
                          color: CustomColors.blueGreen,
                          fontSize: 16,
                          fontFamily: "Georgia"),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "We are Live & Waiting for your ORDER...",
                      style: TextStyle(
                          color: CustomColors.blue,
                          fontSize: 16,
                          fontFamily: "Georgia"),
                    ),
                  ],
                ),
              ),
            );
          } else {
            child = SingleChildScrollView(
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    Order order =
                        Order.fromJson(snapshot.data.documents[index].data);

                    return Card(
                      elevation: 2,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                order.getStatus(),
                                style: TextStyle(
                                    color: CustomColors.purple,
                                    fontSize: 18,
                                    fontFamily: "Georgia"),
                              ),
                              trailing: Icon(Icons.chevron_right, size: 35),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.access_time,
                                size: 35,
                                color: CustomColors.blueGreen,
                              ),
                              title: Text(
                                "Ordered At",
                                style: TextStyle(
                                    color: CustomColors.blue,
                                    fontSize: 14,
                                    fontFamily: "Georgia"),
                              ),
                              trailing: Text(
                                DateUtils.formatDateTime(order.createdAt),
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 12,
                                    fontFamily: "Georgia"),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.person_pin_circle,
                                size: 35,
                                color: CustomColors.blueGreen,
                              ),
                              title: Text(
                                "Delivery Address",
                                style: TextStyle(
                                    color: CustomColors.blue,
                                    fontSize: 14,
                                    fontFamily: "Georgia"),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                  color:
                                      CustomColors.lightPurple.withOpacity(0.5),
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
                            Padding(
                              padding: EdgeInsets.only(left: 70.0, bottom: 10),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    color: CustomColors.lightGrey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .street,
                                          16),
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .city,
                                          6),
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .pincode,
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
                                              text: order.delivery.userLocation
                                                  .userNumber,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    );
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

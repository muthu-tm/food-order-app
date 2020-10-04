import 'package:chipchop_buyer/screens/orders/OrderDetailsScreen.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
import '../app/appBar.dart';
import '../app/bottomBar.dart';
import '../app/sideDrawer.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrdersHomeScreen extends StatefulWidget {
  @override
  _OrdersHomeScreenState createState() => _OrdersHomeScreenState();
}

class _OrdersHomeScreenState extends State<OrdersHomeScreen> {
  String filterBy = "0";

  Map<String, String> _selectedFilter = {
    "0": "All",
    "1": "Ordered",
    "2": "Confirmed",
    "3": "Cancelled BY User",
    "4": "Cancelled BY Store",
    "5": "DisPatched",
    "6": "Delivered",
    "7": "Returned"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: 210,
                  height: 40,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Filter",
                      labelStyle: TextStyle(
                        color: CustomColors.blue,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.white),
                      ),
                    ),
                    items: _selectedFilter.entries.map(
                      (f) {
                        return DropdownMenuItem<String>(
                          value: f.key,
                          child: Text(f.value),
                        );
                      },
                    ).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        filterBy = newVal;
                      });
                    },
                    value: filterBy,
                  ),
                ),
              ),
            ),
            getBody(context),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: Order().streamOrdersByStatus(filterBy == "0" ? null : (int.parse(filterBy) - 1)),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            child = Container(
              child: Center(
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
            child = Container(
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  Order order =
                      Order.fromJson(snapshot.data.documents[index].data);

                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order.uuid),
                            settings: RouteSettings(name: '/orders/details'),
                          ),
                        );
                      },
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
                                Icons.confirmation_number,
                                size: 35,
                                color: CustomColors.blueGreen,
                              ),
                              title: Text(
                                "Order ID",
                                style: TextStyle(
                                    color: CustomColors.blue,
                                    fontSize: 14,
                                    fontFamily: "Georgia"),
                              ),
                              trailing: Text(
                                order.orderID,
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 12,
                                    fontFamily: "Georgia"),
                              ),
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

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
                    SizedBox(
                      height: 20
                    ),
                    Text(
                      "No Orders Found!",
                      style: TextStyle(
                          color: CustomColors.blueGreen,
                          fontSize: 16,
                          fontFamily: "Georgia"),
                    ),
                    SizedBox(
                      height: 20
                    ),
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

                    return Container(
                      child: Text(""),
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
}

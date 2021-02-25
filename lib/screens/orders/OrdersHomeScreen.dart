import 'package:chipchop_buyer/screens/orders/OrderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
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
    return Column(
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
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: Order().streamOrdersByStatus(
          filterBy == "0" ? null : (int.parse(filterBy) - 1)),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
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
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "We are Live & Waiting for your ORDER...",
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 16,
                      ),
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
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  Order order =
                      Order.fromJson(snapshot.data.docs[index].data());

                  return OrderWidget(order);
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

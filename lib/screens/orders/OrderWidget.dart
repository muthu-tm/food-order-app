import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/screens/orders/OrderDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  OrderWidget(this.order);

  final Order order;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order.uuid),
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
  }
}

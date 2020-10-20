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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Store:",
                          style: TextStyle(
                              color: CustomColors.black,
                              fontSize: 14,
                              fontFamily: "Georgia"),
                        ),
                        Text(
                          order.storeName,
                          style: TextStyle(
                              color: CustomColors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: "Georgia"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status:",
                          style: TextStyle(
                              color: CustomColors.black,
                              fontSize: 14,
                              fontFamily: "Georgia"),
                        ),
                        Text(
                          order.getStatus(),
                          style: TextStyle(
                              color: CustomColors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: "Georgia"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.chevron_right, size: 35),
                  ),
                ],
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

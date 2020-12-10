import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class OrderAmountWidget extends StatelessWidget {
  OrderAmountWidget(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    double wOrderAmount = 0.00;
    double cOrderAmount = 0.00;

    if (order.writtenOrders != null &&
        order.writtenOrders.length > 0 &&
        order.writtenOrders.first.name.trim().isNotEmpty) {
      order.writtenOrders.forEach((element) {
        wOrderAmount += element.price;
      });
    }

    if (order.capturedOrders != null && order.capturedOrders.isNotEmpty) {
      order.capturedOrders.forEach((element) {
        cOrderAmount += element.price;
      });
    }

    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Order Amount",
              style: TextStyle(
                  color: CustomColors.black, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Ordered Amount : "),
            trailing: Text('₹ ${order.amount.orderAmount}'),
          ),
          (order.writtenOrders.length > 0 &&
                  order.writtenOrders.first.name.trim().isNotEmpty)
              ? ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Price for Written List : "),
                  trailing: Text('₹ $wOrderAmount'),
                )
              : Container(),
          (order.capturedOrders != null && order.capturedOrders.isNotEmpty)
              ? ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Price for Captured List : "),
                  trailing: Text('₹ $cOrderAmount'),
                )
              : Container(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Wallet Amount : "),
            trailing: Text(
              '₹ ${order.amount.walletAmount}',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Delivery Charge : "),
            trailing: Text('₹ ${order.amount.deliveryCharge}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Total Billed Amount : ",
              style: TextStyle(
                  color: CustomColors.black, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
                '₹ ${order.amount.orderAmount + wOrderAmount + cOrderAmount + order.amount.deliveryCharge - order.amount.walletAmount}'),
          ),
        ],
      ),
    );
  }
}

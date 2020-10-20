import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderAmountWidget extends StatelessWidget {
  OrderAmountWidget(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        color: CustomColors.grey,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                FontAwesomeIcons.moneyBill,
                color: CustomColors.blueGreen,
              ),
              title: Text("Amount Details"),
              trailing: Text(
                  '₹ ${order.amount.orderAmount + order.amount.deliveryCharge}'),
            ),
            Divider(color: CustomColors.white, indent: 65.0),
            ListTile(
              leading: Text(""),
              title: Text("Order Amount"),
              trailing: Text('₹ ${order.amount.orderAmount}'),
            ),
            ListTile(
              leading: Text(""),
              title: Text("Wallet Amount"),
              trailing: Text('₹ ${order.amount.walletAmount}'),
            ),
            ListTile(
              leading: Text(""),
              title: Text("Delivery Charge"),
              trailing: Text('₹ ${order.amount.deliveryCharge}'),
            ),
            Divider(color: CustomColors.white, indent: 65.0),
            ListTile(
              leading: Text(""),
              title: Text("Paid Amount"),
              trailing: Text('₹ ${order.amount.paidAmount}'),
            ),
          ],
        ),
      ),
    );
  }
}

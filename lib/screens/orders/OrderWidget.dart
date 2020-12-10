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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order.orderID, order.uuid),
            settings: RouteSettings(name: '/orders/details'),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  order.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: CustomColors.purple,fontSize: 16),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2),
                    child: Text(
                      DateUtils.formatDateTime(order.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Show Details",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: CustomColors.blue,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 25,
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CustomColors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          order.orderID,
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Price : ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹ ${order.amount.orderAmount + wOrderAmount + cOrderAmount + order.amount.deliveryCharge}',
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Card(
                    elevation: 0,
                    color: order.getBackGround(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        order.getStatus(order.status),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: order.getTextColor(),
                          backgroundColor: order.getBackGround(),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                order.status == 5
                    ? Card(
                        elevation: 0,
                        color: order.getBackGround(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 5),
                              Text(
                                "Delivered at : ",
                                style: TextStyle(
                                    color: order.getTextColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                order.delivery.deliveredAt != null
                                    ? DateUtils.formatDateTime(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            order.delivery.deliveredAt))
                                    : "",
                                style: TextStyle(
                                  color: order.getTextColor(),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : (order.status < 2 || order.status == 4) &&
                            order.delivery.expectedAt != null
                        ? order.delivery.expectedAt <
                                DateTime.now().millisecondsSinceEpoch
                            ? Card(
                                elevation: 0,
                                color: Colors.red[100],
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          "Late by ",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        getArrival().inDays > 1
                                            ? '${getArrival().inDays.toString()} Days'
                                            : getArrival().inHours == 0
                                                ? '${getArrival().inMinutes.toString()} Minutes'
                                                : '${getArrival().inHours.toString()} Hours',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Card(
                                elevation: 0,
                                color: order.getBackGround(),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          "Arriving in ",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: order.getTextColor(),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        getArrival().inDays > 1
                                            ? '${getArrival().inDays.toString()} Days'
                                            : getArrival().inHours == 0
                                                ? '${getArrival().inMinutes.toString()} Minutes'
                                                : '${getArrival().inHours.toString()} Hours',
                                        style: TextStyle(
                                          color: order.getTextColor(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        : (order.status < 2 || order.status == 4) &&
                                order.delivery.expectedAt == null
                            ? Card(
                                elevation: 0,
                                color: order.getBackGround(),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "Not Scheduled",
                                    style: TextStyle(
                                      color: order.getTextColor(),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Duration getArrival() {
    return DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(order.delivery.expectedAt),
    );
  }
}

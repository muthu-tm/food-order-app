import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/OrderAmountWidget.dart';
import 'package:chipchop_buyer/screens/chats/OrderChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrderDeliveryDetailsScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrdersView.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
import '../../services/utils/DateUtils.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen(this.orderID, this.orderUUID);

  final String orderID;
  final String orderUUID;
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _pController = TextEditingController();
  double ratings;

  @override
  void initState() {
    super.initState();
    ratings = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Order : ${widget.orderID}",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[300],
        onPressed: () {
          return _scaffoldKey.currentState.showBottomSheet((context) {
            return Builder(builder: (BuildContext childContext) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: CustomColors.lightGrey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: OrderChatScreen(
                  orderUUID: widget.orderUUID,
                ),
              );
            });
          });
        },
        label: Text(
          "Chat with Store",
          style: TextStyle(color: CustomColors.black),
        ),
        icon: Icon(Icons.chat_bubble, color: CustomColors.black),
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
      stream: Order().streamOrderByID(widget.orderUUID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          Order order = Order.fromJson(snapshot.data.data);

          child = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text("Store"),
                trailing: Text(
                  order.storeName,
                  style: TextStyle(
                    color: CustomColors.purple,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: Text("Order ID"),
                trailing: Text(
                  order.orderID,
                ),
              ),
              ListTile(
                leading: Text("Ordered At"),
                trailing: Text(
                  DateUtils.formatDateTime(order.createdAt),
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: Text(
                  "Delivery Mode",
                ),
                trailing: Text(
                  order.getDeliveryType(),
                ),
              ),
              order.delivery.deliveryType == 3 && order.status != 5
                  ? ListTile(
                      leading: Text(
                        "Delivery At",
                      ),
                      trailing: Text(
                        order.delivery.scheduledDate != null
                            ? DateUtils.formatDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    order.delivery.scheduledDate),
                              )
                            : '',
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: order.statusDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.stop_circle,
                                color: order.statusDetails[index].status == 2 ||
                                        order.statusDetails[index].status == 3
                                    ? CustomColors.alertRed
                                    : CustomColors.green,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.getStatus(
                                        order.statusDetails[index].status)),
                                    Text(
                                      DateUtils.formatDateTime(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            order.statusDetails[index].status ==
                                                    5
                                                ? order.delivery.deliveredAt
                                                : order.statusDetails[index]
                                                    .createdAt),
                                      ),
                                      style: TextStyle(fontSize: 12),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        index != order.statusDetails.length - 1
                            ? Container(
                                height: 40,
                                width: 25,
                                child: VerticalDivider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                              )
                            : index == order.statusDetails.length - 1 &&
                                    (order.status == 0 ||
                                        order.status == 1 ||
                                        order.status == 4)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 25,
                                        child: VerticalDivider(
                                          color: Colors.black,
                                          thickness: 1,
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.stop_circle,
                                              color: CustomColors.blue,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 0, 0, 0),
                                              child: Text(order.status == 0
                                                  ? "Waiting for Order Confirmation"
                                                  : order.status == 1
                                                      ? "Preparing your Order"
                                                      : order.status == 4
                                                          ? "On the Way"
                                                          : ""),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Card(
                elevation: 2,
                child: Container(
                  color: CustomColors.lightGrey,
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Column(
                    children: [
                      OrderAmountWidget(order),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: CustomColors.white,
                          border: Border.all(color: CustomColors.grey),
                        ),
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderViewScreen(order),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("View Order Details"),
                              Icon(Icons.chevron_right)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      order.status <= 1
                          ? Container(
                              decoration: BoxDecoration(
                                color: CustomColors.white,
                                border: Border.all(color: CustomColors.grey),
                              ),
                              padding: EdgeInsets.all(10),
                              child: InkWell(
                                onTap: () async {
                                  await cancelOrder(order, context);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Request Cancellation"),
                                    Icon(Icons.chevron_right)
                                  ],
                                ),
                              ),
                            )
                          : order.status == 5
                              ? Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.white,
                                        border: Border.all(
                                            color: CustomColors.grey),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDeliveryDetails(order),
                                              settings: RouteSettings(
                                                  name: '/order/delivery'),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Delivery Details"),
                                            Icon(Icons.chevron_right)
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.white,
                                        border: Border.all(
                                            color: CustomColors.grey),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                        onTap: () async {
                                          // await cancelOrder(order, context);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Return Items"),
                                            Icon(Icons.chevron_right)
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.white,
                                        border: Border.all(
                                            color: CustomColors.grey),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                        onTap: () async {
                                          // await cancelOrder(order, context);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Replace Items"),
                                            Icon(Icons.chevron_right)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      order.delivery.deliveryType == 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: CustomColors.white,
                                border: Border.all(color: CustomColors.grey),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Pickup From Store",
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        Store store = await Store()
                                            .getStoresByID(order.storeID);
                                        if (store != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewStoreScreen(store),
                                              settings:
                                                  RouteSettings(name: '/store'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "View Store Details",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: CustomColors.blue,
                                                fontSize: 14),
                                          )),
                                          Icon(Icons.chevron_right)
                                        ],
                                      ))
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: CustomColors.white,
                                border: Border.all(color: CustomColors.grey),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Shipping Address",
                                    ),
                                  ),
                                  ListTile(
                                    title: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      padding:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                        color: CustomColors.lightGrey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  order.delivery.userLocation
                                                      .userName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: CustomColors.blue,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: 8,
                                                    right: 8,
                                                    top: 4,
                                                    bottom: 4),
                                                decoration: BoxDecoration(
                                                  color: CustomColors.purple,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                ),
                                                child: Text(
                                                  order.delivery.userLocation
                                                      .locationName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: CustomColors.white,
                                                      fontSize: 10),
                                                ),
                                              )
                                            ],
                                          ),
                                          createAddressText(
                                              order.delivery.userLocation
                                                  .address.street,
                                              6),
                                          createAddressText(
                                              order.delivery.userLocation
                                                  .address.city,
                                              6),
                                          createAddressText(
                                              order.delivery.userLocation
                                                  .address.pincode,
                                              6),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "LandMark : ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: CustomColors.blue),
                                                ),
                                                TextSpan(
                                                  text: order
                                                      .delivery
                                                      .userLocation
                                                      .address
                                                      .landmark,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                                  text: order.delivery
                                                      .userLocation.userNumber,
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 70,
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

  Future cancelOrder(Order order, BuildContext context) async {
    _pController.text = "";

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CustomColors.lightGrey,
          title: Text(
            "Confirm!",
            style: TextStyle(
                color: CustomColors.alertRed,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          content: Container(
            height: 125,
            child: Column(
              children: <Widget>[
                Text("Please help us with the Reason!"),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: false,
                    controller: _pController,
                    decoration: InputDecoration(
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                color: CustomColors.green,
                child: Text(
                  "NO",
                  style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                onPressed: () {
                  _pController.text = "";
                  Navigator.pop(context);
                }),
            FlatButton(
              color: CustomColors.alertRed,
              child: Text(
                "YES",
                style: TextStyle(
                    color: CustomColors.lightGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              onPressed: () async {
                if (_pController.text.trim().isEmpty) {
                  Navigator.pop(context);
                  _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar(
                      "Please provide the reason for cancellation!",
                      2,
                    ),
                  );
                } else {
                  try {
                    await order.cancelOrder(_pController.text.trim());
                    Navigator.pop(context);
                  } catch (err) {
                    print(err);
                    _pController.text = "";
                    Navigator.pop(context);
                    _scaffoldKey.currentState.showSnackBar(
                      CustomSnackBar.errorSnackBar(
                        "Unable to cancel the order!",
                        3,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

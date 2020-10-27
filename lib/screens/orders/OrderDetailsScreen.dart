import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/orders/OrderAmountWidget.dart';
import 'package:chipchop_buyer/screens/chats/OrderChatScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/storage/image_uploader.dart';
import 'package:chipchop_buyer/services/storage/storage_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
  double ratings;

  TabController _controller;
  TextEditingController _feedbackController;
  List<String> imagePaths = [];
  String _userNumber = "0";

  List<Widget> list = [
    Tab(
      icon: Icon(
        Icons.card_travel,
        size: 20,
      ),
      text: "Details",
    ),
    Tab(
      icon: Icon(
        FontAwesomeIcons.moneyBill,
        size: 20,
      ),
      text: "Amount",
    ),
    Tab(
      icon: Icon(
        Icons.local_shipping,
        size: 20,
      ),
      text: "Delivery",
    ),
  ];

  @override
  void initState() {
    super.initState();
    ratings = 0;
    _feedbackController = TextEditingController();
    _controller = TabController(length: list.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Order - ${widget.orderID}",
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
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {
          return _scaffoldKey.currentState.showBottomSheet((context) {
            return Builder(builder: (BuildContext childContext) {
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: CustomColors.lightGrey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: OrderChatScreen(
                    orderUUID: widget.orderUUID,
                  ),
                ),
              );
            });
          });
        },
        label: Text("Chat"),
        icon: Icon(Icons.chat),
      ),
      body: Container(
        child: getBody(context),
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
            children: [
              ListTile(
                leading: Icon(
                  Icons.store,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Store"),
                trailing: Text(
                  order.storeName,
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_basket,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Status"),
                trailing: Text(
                  order.getStatus(),
                  style: TextStyle(
                    color: CustomColors.purple,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: CustomColors.blueGreen,
                ),
                title: Text("Ordered At"),
                trailing: Text(
                  DateUtils.formatDateTime(order.createdAt),
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              order.delivery.deliveryType != 3
                  ? ListTile(
                      leading: Icon(
                        Icons.local_shipping,
                        size: 35,
                        color: CustomColors.blueGreen,
                      ),
                      title: Text(
                        "Delivery",
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Text(
                        order.getDeliveryType(),
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListTile(
                      leading: Icon(
                        Icons.local_shipping,
                        size: 35,
                        color: CustomColors.blueGreen,
                      ),
                      title: Text(
                        "Delivery At",
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 16,
                        ),
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
                    ),
              ListTile(
                leading: Icon(
                  Icons.rate_review,
                  color: CustomColors.blueGreen,
                  size: 35,
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: RaisedButton(
                    onPressed: () {
                      getReviewsAndRatings(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text("Add a review"),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: TabBar(
                    indicatorColor: CustomColors.alertRed,
                    labelColor: CustomColors.blueGreen,
                    unselectedLabelColor: CustomColors.black,
                    controller: _controller,
                    tabs: list),
              ),
              Expanded(
                child: TabBarView(controller: _controller, children: [
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: order.products.length,
                            itemBuilder: (BuildContext context, int index) {
                              return FutureBuilder(
                                future: Products().getByProductID(
                                    order.products[index].productID),
                                builder: (context,
                                    AsyncSnapshot<Products> snapshot) {
                                  Widget child;
                                  if (snapshot.hasData) {
                                    Products _p = snapshot.data;
                                    child = Card(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Container(
                                                  width: 125,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 125,
                                                        height: 125,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: _p
                                                                .getProductImage(),
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Image(
                                                              fit: BoxFit.fill,
                                                              image:
                                                                  imageProvider,
                                                            ),
                                                            progressIndicatorBuilder:
                                                                (context, url,
                                                                        downloadProgress) =>
                                                                    Center(
                                                              child: SizedBox(
                                                                height: 50.0,
                                                                width: 50.0,
                                                                child: CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress,
                                                                    valueColor: AlwaysStoppedAnimation(
                                                                        CustomColors
                                                                            .blue),
                                                                    strokeWidth:
                                                                        2.0),
                                                              ),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(
                                                              Icons.error,
                                                              size: 35,
                                                            ),
                                                            fadeOutDuration:
                                                                Duration(
                                                                    seconds: 1),
                                                            fadeInDuration:
                                                                Duration(
                                                                    seconds: 2),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      150,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '${_p.name}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                              color:
                                                                  CustomColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Weight: ',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: CustomColors
                                                                      .lightBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Text(
                                                            '${_p.weight}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  CustomColors
                                                                      .black,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            child: Text(
                                                              _p.getUnit(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    CustomColors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Price: ',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: CustomColors
                                                                      .lightBlue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5.0),
                                                              child: Text(
                                                                'Rs. ${_p.currentPrice}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                      CustomColors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(5.0),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: FlatButton(
                                                            child: Text(
                                                              "Show Details",
                                                              style: TextStyle(
                                                                  color:
                                                                      CustomColors
                                                                          .blue),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ProductDetailsScreen(
                                                                          _p),
                                                                  settings:
                                                                      RouteSettings(
                                                                          name:
                                                                              '/store/products'),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ListTile(
                                              leading: Text(
                                                "Quantity: ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: CustomColors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              title: Text(
                                                '${order.products[index].quantity.round()}',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: CustomColors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Text(
                                                'Rs. ${order.products[index].amount}',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: CustomColors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.images,
                              color: CustomColors.blueGreen,
                            ),
                            title: Text("Images"),
                          ),
                          order.orderImages.length > 0
                              ? GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  shrinkWrap: true,
                                  primary: false,
                                  mainAxisSpacing: 10,
                                  children: List.generate(
                                    order.orderImages.length,
                                    (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, top: 5),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ImageView(
                                                  url: order.orderImages[index],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    order.orderImages[index],
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Image(
                                                  fit: BoxFit.fill,
                                                  image: imageProvider,
                                                ),
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child: SizedBox(
                                                    height: 50.0,
                                                    width: 50.0,
                                                    child: CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                                CustomColors
                                                                    .blue),
                                                        strokeWidth: 2.0),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  size: 35,
                                                ),
                                                fadeOutDuration:
                                                    Duration(seconds: 1),
                                                fadeInDuration:
                                                    Duration(seconds: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  child: Text(
                                    "No Images added",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: CustomColors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.solidEdit,
                              color: CustomColors.blueGreen,
                            ),
                            title: Text("Written Orders"),
                          ),
                          order.writtenOrders.trim().isNotEmpty
                              ? Container(
                                  child: ListTile(
                                    title: TextFormField(
                                      initialValue: order.writtenOrders,
                                      maxLines: 10,
                                      keyboardType: TextInputType.multiline,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        fillColor: CustomColors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 3.0),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Text(
                                    "No Orders Written",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: CustomColors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          order.status <= 1
                              ? RaisedButton.icon(
                                  color: CustomColors.alertRed,
                                  onPressed: () async {
                                    try {
                                      await order.cancelOrder(order.uuid, "");
                                      Fluttertoast.showToast(
                                          msg: 'Order Cancelled Successfully',
                                          backgroundColor: CustomColors.grey,
                                          textColor: CustomColors.white);
                                    } catch (err) {
                                      print(err);
                                      Fluttertoast.showToast(
                                          msg: 'Error, Unable to Cancel Order',
                                          backgroundColor:
                                              CustomColors.alertRed,
                                          textColor: CustomColors.white);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: CustomColors.lightGrey,
                                  ),
                                  label: Text(
                                    "Cancel Order",
                                    style: TextStyle(
                                        color: CustomColors.lightGrey,
                                        fontSize: 14),
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.all(30),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(child: OrderAmountWidget(order)),
                  SingleChildScrollView(
                    child: Container(
                      color: CustomColors.grey,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.local_shipping,
                              size: 35,
                              color: CustomColors.blueGreen,
                            ),
                            title: Text(
                              "Delivery Address",
                            ),
                          ),
                          ListTile(
                            leading: Text(""),
                            title: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                color: CustomColors.lightGrey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          order.delivery.userLocation.userName,
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
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          order.delivery.userLocation
                                              .locationName,
                                          style: TextStyle(
                                              color: CustomColors.white,
                                              fontSize: 10),
                                        ),
                                      )
                                    ],
                                  ),
                                  createAddressText(
                                      order
                                          .delivery.userLocation.address.street,
                                      6),
                                  createAddressText(
                                      order.delivery.userLocation.address.city,
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
                                          text: "LandMark : ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: CustomColors.blue),
                                        ),
                                        TextSpan(
                                          text: order.delivery.userLocation
                                              .address.landmark,
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
                                          text: order
                                              .delivery.userLocation.userNumber,
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
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.shippingFast,
                              color: CustomColors.blueGreen,
                            ),
                            title: TextFormField(
                              initialValue: order.delivery.expectedAt == null
                                  ? ""
                                  : DateUtils.formatDateTime(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          order.delivery.expectedAt),
                                    ),
                              textAlign: TextAlign.start,
                              autofocus: false,
                              readOnly: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CustomColors.lightGreen),
                                ),
                                labelText: "Expected Delivery Time",
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: CustomColors.blue,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.phone_android,
                              size: 35,
                              color: CustomColors.blueGreen,
                            ),
                            title: TextFormField(
                              initialValue:
                                  order.delivery.deliveryContact ?? "",
                              textAlign: TextAlign.start,
                              autofocus: false,
                              readOnly: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CustomColors.lightGreen),
                                ),
                                labelText: "Delivery - Contact Numer",
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: CustomColors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
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

  getReviewsAndRatings(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Help us improve!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Please rate your experience"),
                  RatingBar(
                    initialRating: ratings,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      ratings = rating;
                    },
                  ),
                  Text("Provide your feedback"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                          ),
                        ),
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: CustomColors.alertRed,
                      onPressed: () async {
                        String imageUrl = '';
                        try {
                          ImagePicker imagePicker = ImagePicker();
                          PickedFile pickedFile;

                          pickedFile = await imagePicker.getImage(
                              source: ImageSource.gallery);
                          if (pickedFile == null) return;

                          String fileName =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          String fbFilePath =
                              'reviews/$_userNumber/$fileName.png';
                          CustomDialogs.actionWaiting(context);
                          // Upload to storage
                          imageUrl = await Uploader().uploadImageFile(
                              true, pickedFile.path, fbFilePath);
                          Navigator.of(context).pop();
                        } catch (err) {
                          Fluttertoast.showToast(
                              msg: 'This file is not an image');
                        }
                        if (imageUrl != "")
                          setState(() {
                            imagePaths.add(imageUrl);
                          });
                      },
                      label: Text(
                        "Add Image",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(FontAwesomeIcons.images),
                    ),
                  ),
                  imagePaths.length > 0
                      ? GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          shrinkWrap: true,
                          primary: false,
                          mainAxisSpacing: 10,
                          children: List.generate(
                            imagePaths.length,
                            (index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 5),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageView(
                                              url: imagePaths[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: CachedNetworkImage(
                                            imageUrl: imagePaths[index],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Image(
                                              fit: BoxFit.fill,
                                              image: imageProvider,
                                            ),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: SizedBox(
                                                height: 50.0,
                                                width: 50.0,
                                                child: CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            CustomColors.blue),
                                                    strokeWidth: 2.0),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              size: 35,
                                            ),
                                            fadeOutDuration:
                                                Duration(seconds: 1),
                                            fadeInDuration:
                                                Duration(seconds: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.alertRed,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.close,
                                          size: 25,
                                          color: CustomColors.white,
                                        ),
                                        onTap: () async {
                                          CustomDialogs.actionWaiting(context);
                                          bool res = await StorageUtils()
                                              .removeFile(imagePaths[index]);
                                          Navigator.of(context).pop();
                                          if (res)
                                            setState(() {
                                              imagePaths
                                                  .remove(imagePaths[index]);
                                            });
                                          else
                                            Fluttertoast.showToast(
                                                msg: 'Unable to remove image');
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {},
                        child: Text("Submit"),
                        color: CustomColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                        color: CustomColors.alertRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
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

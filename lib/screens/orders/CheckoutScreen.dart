import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrderSuccessWidget.dart';
import 'package:chipchop_buyer/screens/user/ViewLocationsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  CheckoutScreen(this.op, this._priceDetails, this.storeID, this.storeName);

  final List<double> _priceDetails;
  final List<OrderProduct> op;
  final String storeID;
  final String storeName;

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  int deliveryOption = 0;
  double wAmount = 0.00;
  bool isAmountUsed = false;
  bool isOutOfRange = false;
  bool isWithinWorkingHours;

  DateTime selectedDate;
  final format = DateFormat('dd MMM, yyyy h:mm a');

  @override
  void initState() {
    super.initState();
    this.selectedDate = DateTime.now().add(Duration(days: 1));

    if (widget._priceDetails.length == 2) {
      isOutOfRange = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Checkout",
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () async {
          try {
            CustomDialogs.actionWaiting(context);
            Order _o = Order();
            OrderAmount _oa = OrderAmount();
            OrderDelivery _od = OrderDelivery();

            _oa.deliveryCharge =
                deliveryOption != 0 ? widget._priceDetails[2] : 0.00;
            _oa.offerAmount = 0.00;
            _oa.walletAmount = wAmount;
            _oa.orderAmount = widget._priceDetails[0];
            _o.amount = _oa;

            _od.userLocation = cachedLocalUser.primaryLocation;
            _od.deliveryType = deliveryOption;
            _od.deliveryCharge =
                deliveryOption != 0 ? widget._priceDetails[2] : 0.00;
            _od.notes = "";
            _od.scheduledDate = deliveryOption == 3
                ? selectedDate.millisecondsSinceEpoch
                : null;
            _o.delivery = _od;

            _o.customerNotes = "";
            _o.status = 0;
            _o.storeName = widget.storeName;
            _o.userNumber = cachedLocalUser.getID();
            _o.storeID = widget.storeID;
            _o.writtenOrders = [];
            _o.capturedOrders = [];
            _o.isReturnable = false;
            _o.products = widget.op;
            _o.totalProducts = widget.op.length;

            await Customers()
                .storeCreateCustomer(widget.storeID, widget.storeName);

            await _o.create();
            await ShoppingCart()
                .clearCartForProduct(widget.storeID, widget.op.first.productID);
            Navigator.of(context).pop();
            showDialog(
                context: _scaffoldKey.currentContext,
                builder: (context) {
                  return OrderSuccessWidget();
                });
          } on PlatformException catch (e) {
            Navigator.of(context).pop();
            if (e.message.contains('offline')) {
              Fluttertoast.showToast(
                  msg: 'Please check your internet and try again',
                  backgroundColor: CustomColors.alertRed,
                  textColor: CustomColors.white);
            } else {
              Fluttertoast.showToast(
                  msg: 'Unable to place order',
                  backgroundColor: CustomColors.alertRed,
                  textColor: CustomColors.white);
            }
          } on Exception catch (err) {
            Analytics.reportError(
                {'type': 'order_create_error', 'error': err.toString()},
                'orders');
            Navigator.of(context).pop();
            Fluttertoast.showToast(
                msg: 'Unable to place order',
                backgroundColor: CustomColors.alertRed,
                textColor: CustomColors.white);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: CustomColors.alertRed,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          height: 40,
          width: 170,
          child: Center(
            child: Text(
              "PLACE ORDER",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Store().getByID(widget.storeID),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return Container();
            } else {
              Store store = Store.fromJson(snapshot.data);

              final currentTime = DateTime.now();
              bool businessHours = (currentTime.isAfter(
                      DateUtils.getTimeAsDateTimeObject(store.activeFrom)) &&
                  currentTime.isBefore(
                      DateUtils.getTimeAsDateTimeObject(store.activeTill)));
              bool businessDays = (DateTime.now().weekday <= 6
                  ? store.workingDays.contains(DateTime.now().weekday)
                  : store.workingDays.contains(0));
              isWithinWorkingHours = businessHours && businessDays;

              child = SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomColors.lightGrey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      this.deliveryOption != 0
                          ? selectedAddressSection()
                          : Container(),
                      isOutOfRange
                          ? onlyPickupOption(store)
                          : deliveyOption(store),
                      Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: getOrderPriceDetails(store),
                      ),
                      Padding(
                        padding: EdgeInsets.all(30),
                      )
                    ],
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            );
          } else {
            child = Container(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            );
          }

          return child;
        },
      ),
    );
  }

  onlyPickupOption(Store store) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(children: [
            Icon(FontAwesomeIcons.infoCircle,
                size: 20, color: CustomColors.alertRed),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                  "You are out of Store delivery Range - ${store.deliveryDetails.maxDistance}KMs. Only SELF PICKUP is Applicable for your Location!"),
            ),
          ]),
          Container(
              margin: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                color: Colors.teal[100],
                border: Border.all(color: Colors.teal[800]),
              ),
              child: ListTile(
                onTap: () async {
                  setState(() {
                    deliveryOption = 0;
                  });
                },
                trailing: Icon(Icons.check_box, color: Colors.teal[800]),
                title: Text(
                  getDeliveryOption(0),
                ),
                subtitle: Text(
                  ' Delivery Charge : FREE ',
                  style: TextStyle(fontSize: 12, color: Colors.teal[800]),
                ),
              )),
          this.deliveryOption == 3
              ? ListTile(
                  leading: Icon(
                    Icons.delivery_dining,
                    size: 40,
                    color: CustomColors.black,
                  ),
                  title: DateTimeField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.date_range,
                          color: CustomColors.blue, size: 30),
                      labelText: "Deliver by",
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: CustomColors.black,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.white),
                      ),
                    ),
                    format: format,
                    initialValue: selectedDate,
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 30),
                        ),
                      );

                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        selectedDate = DateTimeField.combine(date, time);
                        return selectedDate;
                      } else {
                        return currentValue;
                      }
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  deliveyOption(Store store) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(FontAwesomeIcons.shippingFast,
                size: 20, color: CustomColors.alertRed),
            title: Text("Delivery Options"),
          ),
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: store.deliveryDetails.availableOptions.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  color: Colors.teal[100],
                  border: Border.all(color: Colors.teal[800]),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      deliveryOption =
                          store.deliveryDetails.availableOptions[index];
                    });
                  },
                  trailing: Icon(
                      deliveryOption ==
                              store.deliveryDetails.availableOptions[index]
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.teal[800]),
                  title: Text(
                    getDeliveryOption(
                      store.deliveryDetails.availableOptions[index],
                    ),
                  ),
                  subtitle: Text(
                    store.deliveryDetails.availableOptions[index] == 0
                        ? ' Delivery Charge : FREE '
                        : ' Delivery Charge : ₹  ${widget._priceDetails[2]}',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            store.deliveryDetails.availableOptions[index] == 0
                                ? Colors.teal[800]
                                : CustomColors.alertRed),
                  ),
                ),
              );
            },
          ),
          this.deliveryOption == 3
              ? ListTile(
                  leading: Icon(
                    Icons.delivery_dining,
                    size: 40,
                    color: CustomColors.black,
                  ),
                  title: DateTimeField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.date_range,
                          color: CustomColors.blue, size: 30),
                      labelText: "Deliver by",
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: CustomColors.black,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.white),
                      ),
                    ),
                    format: format,
                    initialValue: selectedDate,
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 30),
                        ),
                      );

                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        selectedDate = DateTimeField.combine(date, time);
                        return selectedDate;
                      } else {
                        return currentValue;
                      }
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget getOrderPriceDetails(Store store) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        getWalletWidget(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              createPriceItem(
                  "Ordered Price : ",
                  '₹ ' + widget._priceDetails[0].toString(),
                  CustomColors.black),
              createPriceItem(
                  "Your Savings : ",
                  '₹ ' + widget._priceDetails[1].toString(),
                  CustomColors.green),
              createPriceItem("Wallet Amount : ", '₹ ' + wAmount.toString(),
                  CustomColors.green),
              createPriceItem(
                  "Delivery Charges : ",
                  '₹ ' +
                      (deliveryOption != 0
                          ? widget._priceDetails[2].toString()
                          : 0.00.toString()),
                  CustomColors.black),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total : ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "₹ ${widget._priceDetails[0] + (deliveryOption != 0 ? widget._priceDetails[2] : 0.00) - wAmount}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 5.0),
              Icon(
                Icons.info,
                color: CustomColors.grey,
                size: 20.0,
              ),
              SizedBox(width: 5.0),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "Store may change the Order Price, if you have added",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: CustomColors.alertRed,
                        ),
                      ),
                      TextSpan(
                        text: " `Written Orders / Captured List`",
                        style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ". You may chat with Store for further clarifications. ",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: CustomColors.alertRed,
                        ),
                      ),
                      TextSpan(
                        text: "CHAT HERE",
                        recognizer: TapGestureRecognizer()
                          ..onTap = isWithinWorkingHours
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoreChatScreen(
                                        storeID: store.uuid,
                                        storeName: store.name,
                                      ),
                                      settings:
                                          RouteSettings(name: '/store/chat'),
                                    ),
                                  );
                                }
                              : () {
                                  Fluttertoast.showToast(
                                      msg: 'Store is closed',
                                      backgroundColor: CustomColors.alertRed,
                                      textColor: CustomColors.white);
                                  return;
                                },
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
            child: Row(
          children: [
            SizedBox(width: 10.0),
            Text("* "),
            InkWell(
              onTap: () {
                UrlLauncherUtils.launchURL(terms_and_conditions_url);
              },
              child: Text("Check our Terms of Services",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  )),
            ),
          ],
        )),
      ]),
    );
  }

  Widget getWalletWidget() {
    return StreamBuilder(
      stream: Customers().streamUsersData(widget.storeID),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.exists) {
            Customers cust = Customers.fromJson(snapshot.data.data);

            double walletAmount = cust.availableBalance;

            if (walletAmount != 0.00 && !walletAmount.isNegative) {
              child = ListTile(
                onTap: () {
                  if (walletAmount.isNegative) {
                    Fluttertoast.showToast(
                        msg: 'Cannot Use Wallet',
                        backgroundColor: CustomColors.alertRed,
                        textColor: CustomColors.white);
                    return;
                  }

                  if (!isAmountUsed) {
                    if (walletAmount >
                        (widget._priceDetails[0] +
                            (deliveryOption != 0
                                ? widget._priceDetails[2]
                                : 0.00)))
                      wAmount = widget._priceDetails[0] +
                          (deliveryOption != 0
                              ? widget._priceDetails[2]
                              : 0.00);
                    else
                      wAmount = walletAmount;
                  } else {
                    wAmount = 0;
                  }
                  setState(() {
                    isAmountUsed = !isAmountUsed;
                  });
                },
                leading: Icon(
                  isAmountUsed ? Icons.radio_button_on : Icons.radio_button_off,
                  color: CustomColors.green,
                ),
                title: Text(
                  "Apply Store Wallet Balance",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: CustomColors.blue,
                  ),
                ),
                trailing: Text(
                  "₹ $walletAmount",
                  style: TextStyle(
                    color: walletAmount.isNegative
                        ? CustomColors.alertRed
                        : CustomColors.blue,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else {
              child = Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Store Wallet Balance : ",
                      style: TextStyle(
                          color: CustomColors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "₹ 0.00",
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            child = Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Store Wallet Balance : ",
                    style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "₹ 0.00",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AsyncWidgets.asyncError(),
          );
        } else {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AsyncWidgets.asyncWaiting(),
          );
        }

        return Padding(
          padding: EdgeInsets.all(5.0),
          child: child,
        );
      },
    );
  }

  String getDeliveryOption(int id) {
    switch (id) {
      case 0:
        return "Pickup From Store";
        break;
      case 1:
        return "Instant Delivery";
        break;
      case 2:
        return "Standard Delivery";
        break;
      case 3:
        return "Scheduled Delivery";
        break;
      default:
        return "Standard Delivery";
        break;
    }
  }

  int getDeliveryFee(int id, DeliveryDetails deliveryDetails) {
    switch (id) {
      case 0:
        return -100;
        break;
      case 1:
        return deliveryDetails.instantDelivery;
        break;
      case 2:
        return deliveryDetails.sameDayDelivery;
        break;
      case 3:
        return deliveryDetails.scheduledDelivery;
        break;
      default:
        return deliveryDetails.sameDayDelivery;
        break;
    }
  }

  selectedAddressSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        padding: EdgeInsets.only(left: 12, top: 8, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Delivery Address"),
                  InkWell(
                    child: Icon(
                      Icons.edit,
                      color: CustomColors.alertRed,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewLocationsScreen(),
                          settings: RouteSettings(name: '/location'),
                        ),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                ]),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  cachedLocalUser.primaryLocation.userName ?? "",
                  style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: CustomColors.alertRed,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    cachedLocalUser.primaryLocation.locationName,
                    style: TextStyle(color: CustomColors.white, fontSize: 10),
                  ),
                )
              ],
            ),
            createAddressText(
                cachedLocalUser.primaryLocation.address.street, 5),
            createAddressText(cachedLocalUser.primaryLocation.address.city, 5),
            createAddressText(
                cachedLocalUser.primaryLocation.address.pincode, 5),
            SizedBox(
              height: 6,
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Landmark : ",
                    style: TextStyle(fontSize: 12, color: CustomColors.blue),
                  ),
                  TextSpan(
                    text: cachedLocalUser.primaryLocation.address.landmark,
                    style: TextStyle(color: Colors.black, fontSize: 12),
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
                    style: TextStyle(fontSize: 12, color: CustomColors.blue),
                  ),
                  TextSpan(
                    text: cachedLocalUser.mobileNumber.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              color: Colors.grey.shade300,
              height: 1,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress ?? "",
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  createPriceItem(String key, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }
}

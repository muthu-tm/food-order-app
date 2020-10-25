import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/OrderSuccessWidget.dart';
import 'package:chipchop_buyer/screens/user/ViewLocationsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  CheckoutScreen(this.clearAll, this.op, this._priceDetails, this.storeID,
      this.storeName, this.images, this.writtenOrders);

  final bool clearAll;
  final List<double> _priceDetails;
  final List<String> images;
  final String writtenOrders;
  final List<OrderProduct> op;
  final String storeID;
  final String storeName;

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  int deliveryOption = 0;
  double shippingCharge = 0.00;
  double wAmount = 0.00;
  bool isAmountUsed = false;

  DateTime selectedDate;
  final format = DateFormat("dd-MMM-yyyy HH:mm");

  @override
  void initState() {
    super.initState();
    this.selectedDate = DateTime.now().add(Duration(days: 1));
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
            CustomDialogs.showLoadingDialog(context, _keyLoader);
            Order _o = Order();
            OrderAmount _oa = OrderAmount();
            OrderDelivery _od = OrderDelivery();

            _oa.deliveryCharge = shippingCharge;
            _oa.offerAmount = 0.00;
            _oa.walletAmount = wAmount;
            _oa.orderAmount = widget._priceDetails[0];
            _o.amount = _oa;

            _od.userLocation = cachedLocalUser.primaryLocation;
            _od.deliveryType = deliveryOption;
            _od.deliveryCharge = shippingCharge;
            _od.notes = "";
            _od.scheduledDate = deliveryOption == 3
                ? selectedDate.millisecondsSinceEpoch
                : DateTime.now().millisecondsSinceEpoch;
            _o.delivery = _od;

            _o.customerNotes = "";
            _o.status = 0;
            _o.storeName = widget.storeName;
            _o.userNumber = cachedLocalUser.getID();
            _o.storeID = widget.storeID;
            _o.writtenOrders = widget.writtenOrders;
            _o.orderImages = widget.images;
            _o.isReturnable = false;
            _o.products = widget.op;
            _o.totalProducts = widget.op.length;

            await Customers().storeCreateCustomer(widget.storeID, "");

            await _o.create();
            if (widget.clearAll)
              await ShoppingCart().clearCart();
            else
              await ShoppingCart().clearCartForStore(widget.storeID);
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            showDialog(
                context: _scaffoldKey.currentContext,
                builder: (context) {
                  return OrderSuccessWidget();
                });
          } catch (err) {
            print(err);
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
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.locationArrow,
                          color: CustomColors.alertRed,
                        ),
                        title: Text("Delivery Address"),
                        trailing: Icon(
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
                      selectedAddressSection(),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.shippingFast,
                            color: CustomColors.alertRed),
                        title: Text("Delivery Options"),
                      ),
                      deliveyOption(store),
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

  deliveyOption(Store store) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: CustomColors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: store.deliveryDetails.availableOptions.length,
            itemBuilder: (BuildContext context, int index) {
              int dFee = getDeliveryFee(
                  store.deliveryDetails.availableOptions[index],
                  store.deliveryDetails);

              return Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  color: Color(0xFFE7F9F5),
                  border: Border.all(
                    color: Color(0xFF4CD7A5),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    int dFee = getDeliveryFee(
                        store.deliveryDetails.availableOptions[index],
                        store.deliveryDetails);
                    double fee = 0.00;

                    if (dFee == 0)
                      fee = widget._priceDetails[2];
                    else if (dFee.isNegative) {
                      fee = widget._priceDetails[2] -
                          widget._priceDetails[2] / 100 * dFee.abs();
                      if (fee.isNegative) fee = 0.00;
                    } else {
                      fee = widget._priceDetails[2] +
                          widget._priceDetails[2] / 100 * dFee.abs();
                    }

                    setState(() {
                      shippingCharge = fee;
                      deliveryOption =
                          store.deliveryDetails.availableOptions[index];
                    });
                  },
                  trailing: Icon(
                    deliveryOption ==
                            store.deliveryDetails.availableOptions[index]
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Color(0xFF10CA88),
                  ),
                  title: Text(getDeliveryOption(
                      store.deliveryDetails.availableOptions[index])),
                  subtitle: RichText(
                    text: TextSpan(
                      text: 'Delivery: ',
                      style: TextStyle(
                          color: dFee == 0
                              ? CustomColors.blue
                              : dFee.isNegative
                                  ? CustomColors.green
                                  : CustomColors.alertRed),
                      children: [
                        TextSpan(
                          text: dFee == -100
                              ? 'FREE'
                              : dFee == 0 || dFee == -100
                                  ? ' Standard '
                                  : dFee.isNegative
                                      ? ' ${dFee.abs()}%'
                                      : ' $dFee%',
                          style: TextStyle(
                              color: dFee == 0
                                  ? CustomColors.blue
                                  : dFee.isNegative
                                      ? CustomColors.green
                                      : CustomColors.alertRed),
                        ),
                        TextSpan(
                          text: dFee == -100
                              ? ''
                              : dFee == 0
                                  ? 'Charge'
                                  : dFee.isNegative ? " OFFER" : " Extra Fee",
                          style: TextStyle(
                              color: dFee == 0
                                  ? CustomColors.blue
                                  : dFee.isNegative
                                      ? CustomColors.green
                                      : CustomColors.alertRed),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        this.deliveryOption == 3
            ? ListTile(
                leading: Icon(
                  Icons.av_timer,
                  color: CustomColors.alertRed,
                ),
                title: DateTimeField(
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(Icons.date_range,
                        color: CustomColors.blue, size: 30),
                    labelText: "DateTime",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: CustomColors.blue,
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
        ListTile(
          leading: Icon(
            FontAwesomeIcons.fileInvoiceDollar,
            color: CustomColors.alertRed,
          ),
          title: Text("Price Details"),
        ),
        getWalletWidget(),
        Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.grey.shade200)),
              padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "PRICE DETAILS",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 4,
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
                  createPriceItem(
                      "Order Total",
                      '₹ ' + widget._priceDetails[0].toString(),
                      CustomColors.black),
                  createPriceItem(
                      "Your Savings",
                      '₹ ' + widget._priceDetails[1].toString(),
                      CustomColors.green),
                  createPriceItem("Delievery Charges",
                      '₹ ' + shippingCharge.toString(), CustomColors.black),
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
                        "Total",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      Text(
                        "₹ ${widget._priceDetails[0] + shippingCharge}",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 5.0),
              Icon(
                Icons.info,
                color: CustomColors.alertRed,
                size: 20.0,
              ),
              SizedBox(width: 5.0),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "While Confirming the ORDER, store may update the",
                        style: TextStyle(
                            color: CustomColors.blue,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: " Amount",
                        style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            ", if you have added 'Written Orders/Captured List'",
                        style: TextStyle(
                            color: CustomColors.blue,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              child = Container(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CheckboxListTile(
                      value: isAmountUsed,
                      onChanged: (bool newValue) {
                        if (walletAmount.isNegative) {
                          Fluttertoast.showToast(
                              msg: 'Cannot Use Wallet',
                              backgroundColor: CustomColors.alertRed,
                              textColor: CustomColors.white);
                          return;
                        }

                        if (newValue) {
                          if (walletAmount >
                              widget._priceDetails[0] + shippingCharge)
                            wAmount = widget._priceDetails[0] + shippingCharge;
                          else
                            wAmount = walletAmount;
                        } else {
                          wAmount = 0;
                        }
                        setState(() {
                          isAmountUsed = newValue;
                        });
                      },
                      title: Text(
                        "Apply Balance",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: CustomColors.blue,
                        ),
                      ),
                      secondary: Text(
                        "₹ $walletAmount",
                        style: TextStyle(
                          color: walletAmount.isNegative
                              ? CustomColors.alertRed
                              : CustomColors.green,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: CustomColors.alertRed,
                    ),
                    ListTile(
                      leading: Text(""),
                      title: Text(
                        "Amount Applied",
                        style: TextStyle(
                          color: CustomColors.blue,
                          fontSize: 14.0,
                        ),
                      ),
                      trailing: Text(
                        "₹ $wAmount",
                        style: TextStyle(
                          color: CustomColors.green,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              child = ListTile(
                leading: Text(""),
                title: Text(
                  "Wallet Balance",
                  style: TextStyle(
                    color: CustomColors.blue,
                    fontSize: 14.0,
                  ),
                ),
                trailing: Text(
                  "₹ $walletAmount",
                  style: TextStyle(
                    color: CustomColors.green,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          } else {
            child = ListTile(
              leading: Text(""),
              title: Text(
                "Wallet Balance",
                style: TextStyle(
                  color: CustomColors.blue,
                  fontSize: 14.0,
                ),
              ),
              trailing: Text(
                "₹ 0.00",
                style: TextStyle(
                  color: CustomColors.green,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
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
          child: Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    size: 30.0,
                    color: CustomColors.alertRed,
                  ),
                  title: Text(
                    "Store Wallet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColors.positiveGreen,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Divider(
                  color: CustomColors.blue,
                  height: 0,
                ),
                child,
              ],
            ),
          ),
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
        return "Same-Day Delivery";
        break;
      case 3:
        return "Schedule Delivery";
        break;
      default:
        return "Same-Day Delivery";
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

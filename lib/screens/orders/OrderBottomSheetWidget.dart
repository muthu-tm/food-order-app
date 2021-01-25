import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_captured_image.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/order_written_details.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrderSuccessWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderBottomSheetWidget extends StatefulWidget {
  OrderBottomSheetWidget(
      this.store,
      this.cartItems,
      this.selectedDate,
      this.deliveryOption,
      this.shippingCharge,
      this._priceDetails,
      this._cartWrittenOrders,
      this._cartImagePaths);

  final Store store;
  final List<ShoppingCart> cartItems;
  final DateTime selectedDate;
  final int deliveryOption;
  final double shippingCharge;
  final List<double> _priceDetails;
  final List<WrittenOrders> _cartWrittenOrders;

  final List<String> _cartImagePaths;

  @override
  _OrderBottomSheetWidgetState createState() => _OrderBottomSheetWidgetState();
}

class _OrderBottomSheetWidgetState extends State<OrderBottomSheetWidget> {
  double wAmount = 0.00;
  bool isAmountUsed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: CustomColors.lightGrey,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(10),
            child: Text(
              widget.store.name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
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
                createPriceItem(
                    "Ordered Price : ",
                    '₹ ' + widget._priceDetails[0].toString(),
                    CustomColors.black),
                (widget._cartWrittenOrders.length > 0 &&
                        widget._cartWrittenOrders.first.name.trim().isNotEmpty)
                    ? createPriceItem("Price for Written List : ", '₹ 0.0',
                        CustomColors.black)
                    : Container(),
                (widget._cartImagePaths.length > 0 &&
                        widget._cartImagePaths.isNotEmpty)
                    ? createPriceItem("Price for Captured List : ", '₹ 0.0',
                        CustomColors.black)
                    : Container(),
                createPriceItem(
                    "Your Savings : ",
                    '₹ ' + widget._priceDetails[1].toString(),
                    CustomColors.green),
                createPriceItem("Wallet Amount : ", '₹ ' + wAmount.toString(),
                    CustomColors.green),
                createPriceItem(
                    "Delivery Charges : ",
                    '₹ ' +
                        (widget.deliveryOption == 0
                            ? 0.00.toString()
                            : widget.shippingCharge.toString()),
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
                      "₹ ${widget._priceDetails[0] + (widget.deliveryOption != 0 ? widget.shippingCharge : 0.00) - wAmount}",
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
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreChatScreen(
                                    storeID: widget.store.uuid,
                                    storeName: widget.store.name,
                                  ),
                                  settings: RouteSettings(name: '/store/chat'),
                                ),
                              );
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
          Padding(
            padding: EdgeInsets.all(5),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: CustomColors.green,
              onPressed: () async {
                CustomDialogs.actionWaiting(context);
                Order _o = Order();
                OrderAmount _oa = OrderAmount();
                OrderDelivery _od = OrderDelivery();
                List<OrderProduct> _orderProducts = [];

                for (var i = 0; i < widget.cartItems.length; i++) {
                  ShoppingCart _sc = widget.cartItems[i];
                  Products _p = await Products().getByProductID(_sc.productID);

                  OrderProduct _op = OrderProduct();
                  _op.productID = _p.uuid;
                  _op.productName = _p.name;
                  _op.quantity = _sc.quantity;
                  _op.variantID = _sc.variantID;
                  _op.amount = _sc.quantity *
                      _p.variants[int.parse(_sc.variantID)].currentPrice;
                  _orderProducts.add(_op);
                }

                _oa.deliveryCharge =
                    (widget.deliveryOption != 0 ? widget.shippingCharge : 0.00);
                _oa.offerAmount = 0.00;
                _oa.walletAmount = wAmount;
                _oa.orderAmount = widget._priceDetails[0];
                _o.amount = _oa;

                _od.userLocation = cachedLocalUser.primaryLocation;
                _od.deliveryType = widget.deliveryOption;
                _od.deliveryCharge =
                    (widget.deliveryOption != 0 ? widget.shippingCharge : 0.00);
                _od.notes = "";
                _od.scheduledDate = widget.deliveryOption == 3
                    ? widget.selectedDate.millisecondsSinceEpoch
                    : null;
                _o.delivery = _od;

                _o.customerNotes = "";
                _o.status = 0;
                _o.storeName = widget.store.name;
                _o.userNumber = cachedLocalUser.getID();
                _o.storeID = widget.store.uuid;
                if (widget._cartWrittenOrders.isNotEmpty) {
                  if (widget._cartWrittenOrders.length == 1 &&
                      widget._cartWrittenOrders.first.name.trim().isEmpty)
                    _o.writtenOrders = [];
                  else
                    _o.writtenOrders = widget._cartWrittenOrders;
                } else {
                  _o.writtenOrders = [];
                }
                _o.capturedOrders = widget._cartImagePaths.map((e) {
                  return CapturedOrders.fromJson({'image': e});
                }).toList();
                _o.isReturnable = false;
                _o.products = _orderProducts;
                _o.totalProducts = _orderProducts.length;

                Customers()
                    .storeCreateCustomer(widget.store.uuid, widget.store.name);

                await _o.create();
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) {
                      return OrderSuccessWidget();
                    });
                ShoppingCart().clearCartForStore(widget.store.uuid);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Text(
                  "Order Now",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget getWalletWidget() {
    return StreamBuilder(
      stream: Customers().streamUsersData(widget.store.uuid),
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
                            (widget.deliveryOption != 0
                                ? widget.shippingCharge
                                : 0.00)))
                      wAmount = widget._priceDetails[0] +
                          (widget.deliveryOption != 0
                              ? widget.shippingCharge
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
                    isAmountUsed
                        ? Icons.radio_button_on
                        : Icons.radio_button_off,
                    color: CustomColors.green),
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
          padding: const EdgeInsets.all(5.0),
          child: child,
        );
      },
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
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}

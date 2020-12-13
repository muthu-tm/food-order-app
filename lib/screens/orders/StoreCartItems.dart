import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_amount.dart';
import 'package:chipchop_buyer/db/models/order_captured_image.dart';
import 'package:chipchop_buyer/db/models/order_delivery.dart';
import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/order_written_details.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/TakePicturePage.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrderSuccessWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/user/ViewLocationsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/storage/image_uploader.dart';
import 'package:chipchop_buyer/services/storage/storage_utils.dart';
import 'package:intl/intl.dart';

class StoreCartItems extends StatefulWidget {
  StoreCartItems(this.storeID, this.storeName, this.cartItems);

  final String storeID;
  final String storeName;
  final List<ShoppingCart> cartItems;
  @override
  _StoreCartItemsState createState() => _StoreCartItemsState();
}

class _StoreCartItemsState extends State<StoreCartItems> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<WrittenOrders> _cartWrittenOrders = [WrittenOrders.fromJson({})];

  List<String> _cartImagePaths = [];
  bool textBoxEnabled = false;

  int deliveryOption = 0;
  double shippingCharge = 0.00;
  double wAmount = 0.00;
  bool isAmountUsed = false;
  bool isWithinWorkingHours;

  DateTime selectedDate;
  final format = DateFormat('dd MMM, yyyy h:mm a');

  List<double> _priceDetails = [0.00, 0.00];

  Map<int, String> _units = {
    0: "Nos",
    1: "Kg",
    2: "gram",
    3: "m.gram",
    4: "Litre",
    5: "m.litre"
  };

  @override
  void initState() {
    super.initState();

    Store().getShippingChargeByID(widget.storeID).then((value) {
      setState(() {
        shippingCharge = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store>(
      future: Store().getStoresByID(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<Store> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return Container();
          } else {
            Store store = snapshot.data;
            final currentTime = DateTime.now();
            isWithinWorkingHours = (currentTime.isAfter(
                        DateUtils.getTimeAsDateTimeObject(store.activeFrom)) &&
                    currentTime.isBefore(
                        DateUtils.getTimeAsDateTimeObject(store.activeTill))) &&
                (DateTime.now().weekday <= 6
                    ? store.workingDays.contains(DateTime.now().weekday)
                    : store.workingDays.contains(0));

            double tAmount = 0.00;
            double oPrice = 0.00;

            List<OrderProduct> _orderProducts = [];

            child = Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900]),
                            ),
                            Text(
                              store.address.city,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewStoreScreen(store),
                                settings: RouteSettings(name: '/store'),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 20,
                              ),
                              Text(
                                "Buy More",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: widget.cartItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    ShoppingCart _sc = widget.cartItems[index];

                    return FutureBuilder<Products>(
                      future: Products().getByProductID(_sc.productID),
                      builder: (BuildContext context,
                          AsyncSnapshot<Products> snapshot) {
                        Widget child;

                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            Products _p = snapshot.data;

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              OrderProduct _op = OrderProduct();
                              _op.productID = _p.uuid;
                              _op.productName = _p.name;
                              _op.quantity = _sc.quantity;
                              _op.variantID = _sc.variantID;
                              _op.amount = _sc.quantity *
                                  _p.variants[int.parse(_sc.variantID)]
                                      .currentPrice;
                              _orderProducts.add(_op);

                              tAmount += _sc.quantity *
                                  _p.variants[int.parse(_sc.variantID)]
                                      .currentPrice;
                              oPrice += _sc.quantity *
                                  _p.variants[int.parse(_sc.variantID)].offer;

                              _priceDetails = [tAmount, oPrice];
                            }

                            child = buildShoppingCartItem(context, _sc, _p);
                          }
                        } else if (snapshot.hasError) {
                          child = Center(
                            child: Container(
                              height: 100,
                              child: Column(
                                children: AsyncWidgets.asyncError(),
                              ),
                            ),
                          );
                        } else {
                          child = Center(
                            child: Container(
                              height: 100,
                              child: Column(
                                children: AsyncWidgets.asyncWaiting(),
                              ),
                            ),
                          );
                        }
                        return child;
                      },
                    );
                  },
                ),
                getCartDetailsCards(store),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color:
                        isWithinWorkingHours ? CustomColors.green : Colors.grey,
                    onPressed: () async {
                      if (cachedLocalUser.primaryLocation == null) {
                        Fluttertoast.showToast(
                            msg:
                                'Primary Location not found, Please add/set Location',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }

                      if (!isWithinWorkingHours) {
                        Fluttertoast.showToast(
                            msg: 'Cannot Place Order Now. Store is closed !',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }

                      if (widget.cartItems.isEmpty &&
                          (_cartWrittenOrders.length > 0 &&
                              _cartWrittenOrders.first.name.trim().isEmpty) &&
                          _cartImagePaths.isEmpty) {
                        Fluttertoast.showToast(
                            msg: 'Nothing to Order !!',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }

                      CustomDialogs.actionWaiting(context);
                      Order _o = Order();
                      OrderAmount _oa = OrderAmount();
                      OrderDelivery _od = OrderDelivery();

                      _oa.deliveryCharge =
                          (deliveryOption != 0 ? shippingCharge : 0.00);
                      _oa.offerAmount = 0.00;
                      _oa.walletAmount = wAmount;
                      _oa.orderAmount = _priceDetails[0];
                      _o.amount = _oa;

                      _od.userLocation = cachedLocalUser.primaryLocation;
                      _od.deliveryType = deliveryOption;
                      _od.deliveryCharge =
                          (deliveryOption != 0 ? shippingCharge : 0.00);
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
                      if (_cartWrittenOrders.length > 0 &&
                          _cartWrittenOrders.first.name.trim().isNotEmpty) {
                        _o.writtenOrders = _cartWrittenOrders;
                      } else {
                        _o.writtenOrders = [];
                      }
                      _o.capturedOrders = _cartImagePaths.map((e) {
                        return CapturedOrders.fromJson({'image': e});
                      }).toList();
                      _o.isReturnable = false;
                      _o.products = _orderProducts;
                      _o.totalProducts = _orderProducts.length;

                      Customers().storeCreateCustomer(
                          widget.storeID, widget.storeName);

                      await _o.create();
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return OrderSuccessWidget();
                          });
                      ShoppingCart().clearCartForStore(widget.storeID);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      child: Text(
                        "Place Order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: isWithinWorkingHours
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
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
    );
  }

  Widget getCartDetailsCards(Store store) {
    return Column(
      children: [
        Card(
          elevation: 2,
          color: Colors.blue[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTileTheme(
            dense: true,
            child: ExpansionTile(
              backgroundColor: CustomColors.white,
              title: Text(
                "Missing few products you're looking for ? Add here !!",
                style: TextStyle(fontSize: 12),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Think & Write it down now !!",
                      style: TextStyle(
                          fontSize: 14,
                          color: CustomColors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 135,
                      child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        color: Colors.green,
                        onPressed: () async {
                          if (_cartWrittenOrders.isNotEmpty &&
                              _cartWrittenOrders.last.name.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please fill the Product Name");
                            return;
                          } else {
                            setState(() {
                              _cartWrittenOrders
                                  .add(WrittenOrders.fromJson({}));
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text(
                          "Add",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _cartWrittenOrders.length,
                    itemBuilder: (BuildContext context, int index) {
                      WrittenOrders _wr = _cartWrittenOrders[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  initialValue: _wr.name,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    labelText: "Product Name",
                                    fillColor: CustomColors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 3.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: CustomColors.white),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _wr.name = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: TextFormField(
                                        initialValue: _wr.weight.toString(),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(
                                                  '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'),
                                              replacementString: 0.toString()),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: "Weight",
                                          fillColor: CustomColors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 3.0, horizontal: 3.0),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: CustomColors.white),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _wr.weight = double.parse(val);
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border:
                                              Border.all(color: Colors.black54),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            hint: Text(
                                              "Unit",
                                            ),
                                            value: _wr.unit.toString(),
                                            items: _units.entries.map((f) {
                                              return DropdownMenuItem<String>(
                                                value: f.key.toString(),
                                                child: Text(f.value),
                                              );
                                            }).toList(),
                                            onChanged: (unit) {
                                              setState(
                                                () {
                                                  _wr.unit = int.parse(unit);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        initialValue: _wr.quantity.toString(),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[0-9]*$'),
                                              replacementString: 0.toString()),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: "Quantity",
                                          fillColor: CustomColors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 3.0, horizontal: 3.0),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: CustomColors.white),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _wr.quantity = int.parse(val);
                                          });
                                        },
                                      ),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      );
                    }),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "Already your list is Ready ?",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            "Capture & Order",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15,
                                color: CustomColors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 135,
                        child: FlatButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: Colors.green,
                          onPressed: () async {
                            String tempPath =
                                (await getTemporaryDirectory()).path;
                            String filePath =
                                '$tempPath/order_image_${_cartImagePaths.length}.png';
                            if (File(filePath).existsSync())
                              await File(filePath).delete();

                            List<CameraDescription> cameras =
                                await availableCameras();
                            CameraDescription camera = cameras.first;

                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TakePicturePage(
                                  camera: camera,
                                  path: filePath,
                                ),
                              ),
                            );
                            if (result != null) {
                              String imageUrl = "";
                              try {
                                String fileName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                String fbFilePath =
                                    'orders/${cachedLocalUser.getID()}/$fileName.png';
                                CustomDialogs.showLoadingDialog(
                                    context, _keyLoader);
                                // Upload to storage
                                imageUrl = await Uploader().uploadImageFile(
                                    true, result.toString(), fbFilePath);
                                Navigator.of(_keyLoader.currentContext,
                                        rootNavigator: true)
                                    .pop();
                              } catch (err) {
                                Fluttertoast.showToast(
                                    msg: 'This file is not an image');
                              }
                              if (imageUrl != "")
                                setState(() {
                                  _cartImagePaths.add(imageUrl);
                                });
                            }
                          },
                          icon: Icon(Icons.camera),
                          label: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              "Capture",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _cartImagePaths.length > 0
                    ? SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          primary: true,
                          shrinkWrap: true,
                          itemCount: _cartImagePaths.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 5),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImageView(
                                                url: _cartImagePaths[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: CachedNetworkImage(
                                              imageUrl: _cartImagePaths[index],
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Image(
                                                fit: BoxFit.fill,
                                                height: 200,
                                                width: 200,
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
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: CustomColors.alertRed,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: InkWell(
                                            child: Icon(
                                              Icons.close,
                                              size: 30,
                                              color: CustomColors.white,
                                            ),
                                            onTap: () async {
                                              CustomDialogs.showLoadingDialog(
                                                  context, _keyLoader);
                                              bool res = await StorageUtils()
                                                  .removeFile(
                                                      _cartImagePaths[index]);
                                              Navigator.of(
                                                      _keyLoader.currentContext,
                                                      rootNavigator: true)
                                                  .pop();
                                              if (res)
                                                setState(() {
                                                  _cartImagePaths.remove(
                                                      _cartImagePaths[index]);
                                                });
                                              else
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Unable to remove image');
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text("Amount : ₹ 0.00")
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTileTheme(
            dense: true,
            child: ExpansionTile(
              backgroundColor: CustomColors.grey,
              onExpansionChanged: (val) {
                if (val) setState(() {});
              },
              title: Text(
                "My Delivery Options",
                style: TextStyle(fontSize: 14, color: CustomColors.black),
              ),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: CustomColors.lightGrey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      deliveryOption != 0
                          ? Column(
                              children: [
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
                                        builder: (context) =>
                                            ViewLocationsScreen(),
                                        settings:
                                            RouteSettings(name: '/location'),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  },
                                ),
                                selectedAddressSection(),
                              ],
                            )
                          : Container(),
                      deliveyOption(store),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTileTheme(
            dense: true,
            child: ExpansionTile(
              backgroundColor: CustomColors.grey,
              onExpansionChanged: (val) {
                if (val) setState(() {});
              },
              title: Text(
                "Order Price Details",
                style: TextStyle(fontSize: 14, color: CustomColors.black),
              ),
              children: [getOrderPriceDetails(store)],
            ),
          ),
        ),
      ],
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
                  onTap: () async {
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
                        : ' Delivery Charge : ₹  $shippingCharge',
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
        color: CustomColors.lightGrey,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
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
              createPriceItem("Ordered Price : ",
                  '₹ ' + _priceDetails[0].toString(), CustomColors.black),
              (_cartWrittenOrders.length > 0 &&
                      _cartWrittenOrders.first.name.trim().isNotEmpty)
                  ? createPriceItem(
                      "Price for Written List : ", '₹ 0.0', CustomColors.black)
                  : Container(),
              (_cartImagePaths.length > 0 && _cartImagePaths.isNotEmpty)
                  ? createPriceItem(
                      "Price for Captured List : ", '₹ 0.0', CustomColors.black)
                  : Container(),
              createPriceItem("Your Savings : ",
                  '₹ ' + _priceDetails[1].toString(), CustomColors.green),
              createPriceItem("Wallet Amount : ", '₹ ' + wAmount.toString(),
                  CustomColors.green),
              createPriceItem(
                  "Delivery Charges : ",
                  '₹ ' +
                      (this.deliveryOption == 0
                          ? 0.00.toString()
                          : shippingCharge.toString()),
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
                    "₹ ${_priceDetails[0] + (deliveryOption != 0 ? shippingCharge : 0.00) - wAmount}",
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
              child = Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        InkWell(
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
                                  _priceDetails[0] +
                                      (deliveryOption != 0
                                          ? shippingCharge
                                          : 0.00))
                                wAmount = _priceDetails[0] +
                                    (deliveryOption != 0
                                        ? shippingCharge
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
                          child: Icon(isAmountUsed
                              ? Icons.radio_button_on
                              : Icons.radio_button_off),
                        ),
                        Text(
                          "Apply Store Wallet Balance : ",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: CustomColors.blue,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹ $walletAmount",
                      style: TextStyle(
                        color: walletAmount.isNegative
                            ? CustomColors.alertRed
                            : CustomColors.blue,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

  Widget buildShoppingCartItem(
      BuildContext context, ShoppingCart sc, Products _p) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 110,
              height: 125,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: _p.getProductImage(),
                  imageBuilder: (context, imageProvider) => Image(
                    fit: BoxFit.fill,
                    image: imageProvider,
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                          valueColor: AlwaysStoppedAnimation(CustomColors.blue),
                          strokeWidth: 2.0),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: 35,
                  ),
                  fadeOutDuration: Duration(seconds: 1),
                  fadeInDuration: Duration(seconds: 2),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 130,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _p.brandName != null && _p.brandName.isNotEmpty
                          ? Expanded(
                              child: Text(
                                '${_p.brandName}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: CustomColors.black),
                              ),
                            )
                          : Expanded(child: Container()),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(_p),
                              settings: RouteSettings(name: '/store/products'),
                            ),
                          );
                        },
                        child: Text(
                          "Show Details",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_p.name}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: CustomColors.black, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_p.variants[int.parse(sc.variantID)].weight}',
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: CustomColors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              _p.variants[int.parse(sc.variantID)].getUnit(),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: CustomColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue[100]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            sc.quantity == 1.0
                                ? InkWell(
                                    onTap: () async {
                                      try {
                                        CustomDialogs.showLoadingDialog(
                                            context, _keyLoader);
                                        await ShoppingCart().removeItem(false,
                                            _p.storeID, _p.uuid, sc.variantID);
                                        Navigator.of(_keyLoader.currentContext,
                                                rootNavigator: true)
                                            .pop();
                                      } catch (err) {
                                        print(err);
                                      }
                                    },
                                    child: SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Icon(Icons.delete_forever),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      try {
                                        CustomDialogs.showLoadingDialog(
                                            context, _keyLoader);
                                        await ShoppingCart().updateCartQuantity(
                                            false,
                                            _p.storeID,
                                            _p.uuid,
                                            sc.variantID);
                                        Navigator.of(_keyLoader.currentContext,
                                                rootNavigator: true)
                                            .pop();
                                      } catch (err) {
                                        print(err);
                                      }
                                    },
                                    child: SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Icon(Icons.remove),
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 10.0),
                              child: Text(
                                sc.quantity.round().toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: CustomColors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                try {
                                  CustomDialogs.showLoadingDialog(
                                      context, _keyLoader);
                                  await ShoppingCart().updateCartQuantity(
                                      true, _p.storeID, _p.uuid, sc.variantID);
                                  Navigator.of(_keyLoader.currentContext,
                                          rootNavigator: true)
                                      .pop();
                                } catch (err) {
                                  print(err);
                                }
                              },
                              child: SizedBox(
                                width: 35,
                                height: 35,
                                child: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '₹ ${_p.variants[int.parse(sc.variantID)].currentPrice.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.black,
                          ),
                        ),
                      ),
                      !_p.isDeliverable
                          ? Row(
                              children: [
                                Text(
                                  "Only Self Pickup",
                                  style: TextStyle(
                                      color: CustomColors.alertRed,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                InkWell(
                                    child: Icon(
                                      Icons.info,
                                      size: 15,
                                      color: CustomColors.grey,
                                    ),
                                    onTap: () {})
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            try {
                              CustomDialogs.showLoadingDialog(
                                  context, _keyLoader);
                              bool res = await ShoppingCart().moveToWishlist(
                                  sc.uuid,
                                  sc.storeID,
                                  sc.productID,
                                  sc.variantID);
                              Navigator.of(_keyLoader.currentContext,
                                      rootNavigator: true)
                                  .pop();

                              if (!res)
                                Fluttertoast.showToast(
                                    msg:
                                        'This Product already in Your WishList !');
                            } catch (err) {
                              print(err);
                            }
                          },
                          child: Container(
                            height: 25,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green[100]),
                            child: Text(
                              "Move To Wishlist",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            try {
                              CustomDialogs.showLoadingDialog(
                                  context, _keyLoader);
                              await ShoppingCart().removeItem(false, sc.storeID,
                                  sc.productID, sc.variantID);
                              Navigator.of(_keyLoader.currentContext,
                                      rootNavigator: true)
                                  .pop();
                            } catch (err) {
                              print(err);
                            }
                          },
                          child: Container(
                            height: 25,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red[100]),
                            child: Text(
                              "Remove",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';
import 'package:chipchop_buyer/db/models/order_written_details.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/TakePicturePage.dart';
import 'package:chipchop_buyer/screens/orders/OrderBottomSheetWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
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

  int deliveryOption;
  bool isOutOfRange = false;
  double shippingCharge = 0.00;
  double tempShippingCharge = 0.00;
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
    this.selectedDate = DateTime.now().add(Duration(days: 1));

    Store().getShippingChargeByID(widget.storeID).then((value) {
      if (value == -1000.0) {
        setState(() {
          isOutOfRange = true;
        });
      } else {
        setState(() {
          shippingCharge = value;
          tempShippingCharge = value;
        });
      }
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
                            if (!store.isActive) {
                              Fluttertoast.showToast(
                                  msg:
                                      "Store ${store.name} is not Live Now. Try Later!",
                                  backgroundColor: CustomColors.alertRed,
                                  textColor: CustomColors.white);
                              return;
                            }

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

                      if (deliveryOption == null) {
                        Fluttertoast.showToast(
                            msg: 'Select any Delivery Option!!',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }

                      showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return OrderBottomSheetWidget(
                                store,
                                widget.cartItems,
                                selectedDate,
                                deliveryOption,
                                shippingCharge,
                                _priceDetails,
                                _cartWrittenOrders,
                                _cartImagePaths);
                          });
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
                Column(
                  children: [
                    _cartWrittenOrders.length == 1
                        ? Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          initialValue:
                                              _cartWrittenOrders[0].name,
                                          keyboardType: TextInputType.text,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                            labelText: "Product Name",
                                            fillColor: CustomColors.white,
                                            filled: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 10.0),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CustomColors.white),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _cartWrittenOrders[0].name = val;
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
                                                initialValue:
                                                    _cartWrittenOrders[0]
                                                        .weight
                                                        .toString(),
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(
                                                          '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'),
                                                      replacementString:
                                                          0.toString()),
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: "Weight",
                                                  fillColor: CustomColors.white,
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 3.0,
                                                          horizontal: 10.0),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            CustomColors.white),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _cartWrittenOrders[0]
                                                            .weight =
                                                        double.parse(val);
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
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black54),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    hint: Text(
                                                      "Unit",
                                                    ),
                                                    value: _cartWrittenOrders[0]
                                                        .unit
                                                        .toString(),
                                                    items:
                                                        _units.entries.map((f) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: f.key.toString(),
                                                        child: Text(f.value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (unit) {
                                                      setState(
                                                        () {
                                                          _cartWrittenOrders[0]
                                                                  .unit =
                                                              int.parse(unit);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                  color: Colors.lightBlue[200],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.remove),
                                                      onPressed:
                                                          _cartWrittenOrders[0]
                                                                      .quantity <=
                                                                  1
                                                              ? () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Quantity cannot be less than one");
                                                                }
                                                              : () {
                                                                  setState(() {
                                                                    _cartWrittenOrders[
                                                                            0]
                                                                        .quantity = (--_cartWrittenOrders[
                                                                            0]
                                                                        .quantity);
                                                                  });
                                                                }),
                                                  Text(_cartWrittenOrders[0]
                                                      .quantity
                                                      .toString()),
                                                  IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          _cartWrittenOrders[0]
                                                                  .quantity =
                                                              (++_cartWrittenOrders[
                                                                      0]
                                                                  .quantity);
                                                        });
                                                      }),
                                                ],
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _cartWrittenOrders.length,
                            itemBuilder: (BuildContext context, int index) {
                              WrittenOrders _wr = _cartWrittenOrders[index];

                              return Padding(
                                key: ObjectKey(_wr),
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
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
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 3.0,
                                                        horizontal: 10.0),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          CustomColors.white),
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
                                        IconButton(
                                            icon: Icon(
                                              Icons.delete_forever,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _cartWrittenOrders
                                                    .removeAt(index);
                                                _cartWrittenOrders
                                                    .forEach((element) {
                                                  print(element.toJson());
                                                });
                                              });
                                            })
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: TextFormField(
                                                initialValue:
                                                    _wr.weight.toString(),
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(
                                                      RegExp(
                                                          '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$'),
                                                      replacementString:
                                                          0.toString()),
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: "Weight",
                                                  fillColor: CustomColors.white,
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 3.0,
                                                          horizontal: 10.0),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            CustomColors.white),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _wr.weight =
                                                        double.parse(val);
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
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black54),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    hint: Text(
                                                      "Unit",
                                                    ),
                                                    value: _wr.unit.toString(),
                                                    items:
                                                        _units.entries.map((f) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: f.key.toString(),
                                                        child: Text(f.value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (unit) {
                                                      setState(
                                                        () {
                                                          _wr.unit =
                                                              int.parse(unit);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                  color: Colors.lightBlue[200],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.remove),
                                                      onPressed:
                                                          _cartWrittenOrders[
                                                                          index]
                                                                      .quantity <=
                                                                  1
                                                              ? () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Quantity cannot be less than one");
                                                                }
                                                              : () {
                                                                  setState(() {
                                                                    _cartWrittenOrders[
                                                                            index]
                                                                        .quantity = (--_cartWrittenOrders[
                                                                            index]
                                                                        .quantity);
                                                                  });
                                                                }),
                                                  Text(_cartWrittenOrders[index]
                                                      .quantity
                                                      .toString()),
                                                  IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          _cartWrittenOrders[
                                                                      index]
                                                                  .quantity =
                                                              (++_cartWrittenOrders[
                                                                      index]
                                                                  .quantity);
                                                        });
                                                      }),
                                                ],
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              );
                            }),
                  ],
                ),
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
                                              bool res =
                                                  await StorageUtils.removeFile(
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
                                  // trailing: Icon(
                                  //   Icons.edit,
                                  //   color: CustomColors.alertRed,
                                  // ),
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           ViewLocationsScreen(),
                                  //       settings:
                                  //           RouteSettings(name: '/location'),
                                  //     ),
                                  //   ).then((value) {
                                  //     setState(() {});
                                  //   });
                                  // },
                                ),
                                selectedAddressSection(),
                              ],
                            )
                          : Container(),
                      isOutOfRange
                          ? onlyPickupOption(store)
                          : deliveyOption(store),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              int dFee = getDeliveryFee(
                  store.deliveryDetails.availableOptions[index],
                  store.deliveryDetails);

              double dCharge = tempShippingCharge;
              double fee = 0.00;

              if (dFee == 0)
                fee = dCharge;
              else if (dFee.isNegative) {
                fee = dCharge - dCharge / 100 * dFee.abs();
                if (fee.isNegative) fee = 0.00;
              } else {
                fee = dCharge + dCharge / 100 * dFee.abs();
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  color: Colors.teal[100],
                  border: Border.all(color: Colors.teal[800]),
                ),
                //       child: ListTile(
                //         onTap: () async {
                //           setState(() {
                //             deliveryOption =
                //                 store.deliveryDetails.availableOptions[index];
                //           });
                //         },
                //         trailing: Icon(
                //             deliveryOption ==
                //                     store.deliveryDetails.availableOptions[index]
                //                 ? Icons.check_box
                //                 : Icons.check_box_outline_blank,
                //             color: Colors.teal[800]),
                //         title: Text(
                //           getDeliveryOption(
                //             store.deliveryDetails.availableOptions[index],
                //           ),
                //         ),
                //         subtitle: Text(
                //           store.deliveryDetails.availableOptions[index] == 0
                //               ? ' Delivery Charge : FREE '
                //               : ' Delivery Charge : ₹  $shippingCharge',
                //           style: TextStyle(
                //               fontSize: 12,
                //               color:
                //                   store.deliveryDetails.availableOptions[index] == 0
                //                       ? Colors.teal[800]
                //                       : CustomColors.alertRed),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                child: ListTile(
                  onTap: () async {
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
                      color: Colors.teal[800]),
                  title: Text(getDeliveryOption(
                          store.deliveryDetails.availableOptions[index]) +
                      ': ₹  $fee'),
                  subtitle: RichText(
                    text: TextSpan(
                      text: 'Delivery: ',
                      style: TextStyle(color: CustomColors.alertRed),
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
                                      ? Colors.green
                                      : CustomColors.alertRed),
                        ),
                        TextSpan(
                          text: dFee == -100
                              ? ''
                              : dFee == 0
                                  ? 'Charge'
                                  : dFee.isNegative
                                      ? " OFFER"
                                      : " Extra Fee",
                          style: TextStyle(
                              color: dFee == 0
                                  ? CustomColors.blue
                                  : dFee.isNegative
                                      ? Colors.green
                                      : CustomColors.alertRed),
                        ),
                      ],
                    ),
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

  Widget buildShoppingCartItem(
      BuildContext context, ShoppingCart sc, Products _p) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(_p),
              settings: RouteSettings(name: '/store/products'),
            ),
          );
        },
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
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: _p.getProductImage(),
                    imageBuilder: (context, imageProvider) => Image(
                      fit: BoxFit.fill,
                      image: imageProvider,
                    ),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            valueColor:
                                AlwaysStoppedAnimation(CustomColors.blue),
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
                    Text(
                      '${_p.name}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 13,
                          color: CustomColors.black,
                          fontWeight: FontWeight.bold),
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
                          width: 90,
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
                                          await ShoppingCart().removeItem(
                                              false,
                                              _p.storeID,
                                              _p.uuid,
                                              sc.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Icon(
                                          Icons.delete_forever,
                                          size: 18,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart()
                                              .updateCartQuantity(
                                                  false,
                                                  _p.storeID,
                                                  _p.uuid,
                                                  sc.variantID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Icon(
                                          Icons.remove,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                                child: Text(
                                  sc.quantity.round().toString(),
                                  style: TextStyle(
                                      fontSize: 13,
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
                                        true,
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
                                  width: 30,
                                  height: 30,
                                  child: Icon(Icons.add, size: 18),
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
                                    fontSize: 11,
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
                                await ShoppingCart().removeItem(false,
                                    sc.storeID, sc.productID, sc.variantID);
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
                                    fontSize: 11,
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
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/TakePicturePage.dart';
import 'package:chipchop_buyer/screens/orders/EmptyCartWidget.dart';
import 'package:chipchop_buyer/screens/orders/CheckoutScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/storage/image_uploader.dart';
import 'package:chipchop_buyer/services/storage/storage_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/CustomColors.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<String> imagePaths = [];
  String writtenOrders = "";
  bool textBoxEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
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
      body: SingleChildScrollView(
        child: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: ShoppingCart().streamCartItems(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            child = Padding(
              padding: EdgeInsets.all(5.0),
              child: EmptyCartWidget(),
            );
          } else {
            child = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        ShoppingCart _sc = ShoppingCart.fromJson(
                            snapshot.data.documents[index].data);

                        if (index == snapshot.data.documents.length - 1) {
                          return buildShoppingCartItem(context, _sc);
                        } else {
                          return buildShoppingCartItem(context, _sc);
                        }
                      },
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "Already got the list READY?",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: "Georgia",
                                fontSize: 14,
                                color: CustomColors.alertRed,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: Container(
                            width: 75,
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "You're GREAT!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  fontSize: 15,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          trailing: Container(
                            width: 175,
                            child: FlatButton.icon(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: CustomColors.grey,
                              onPressed: () async {
                                String tempPath =
                                    (await getTemporaryDirectory()).path;
                                String filePath =
                                    '$tempPath/order_image_${imagePaths.length}.png';
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
                                      imagePaths.add(imageUrl);
                                    });
                                }
                              },
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                child: Text(
                                  "Capture IT!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Georgia",
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              icon: Icon(FontAwesomeIcons.cameraRetro),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  imagePaths.length > 0
                      ? GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.95,
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
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          bool res = await StorageUtils()
                                              .removeFile(imagePaths[index]);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "Missing Few Products?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "Georgia",
                                fontSize: 14,
                                color: CustomColors.alertRed,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: Container(
                            width: 75,
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "No Worries!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  fontSize: 15,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          trailing: Container(
                            width: 175,
                            child: FlatButton.icon(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: CustomColors.blueGreen,
                              onPressed: () async {
                                if (textBoxEnabled)
                                  setState(() {
                                    textBoxEnabled = false;
                                  });
                                else
                                  setState(() {
                                    textBoxEnabled = true;
                                  });
                              },
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                child: Text(
                                  "Write it OUT",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Georgia",
                                      fontSize: 16,
                                      color: CustomColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              icon: Icon(FontAwesomeIcons.solidEdit),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  textBoxEnabled
                      ? Container(
                          child: ListTile(
                            title: TextFormField(
                              initialValue: writtenOrders,
                              maxLines: 10,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: "Ex, Biriyani Rice - 5 Kg",
                                fillColor: CustomColors.white,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 3.0),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColors.white),
                                ),
                              ),
                              onChanged: (value) {
                                this.writtenOrders = value.trim();
                              },
                            ),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: CustomColors.green,
                      onPressed: () async {
                        if (snapshot.data.documents.isEmpty) {
                          return;
                        }

                        CustomDialogs.showLoadingDialog(context, _keyLoader);

                        double cPrice = 0.00;
                        double oPrice = 0.00;
                        List<OrderProduct> op = [];
                        for (var item in snapshot.data.documents) {
                          OrderProduct _op = OrderProduct();
                          ShoppingCart _sc = ShoppingCart.fromJson(item.data);
                          Products p =
                              await Products().getByProductID(_sc.productID);
                          cPrice += _sc.quantity * p.currentPrice;
                          oPrice += _sc.quantity * p.offer;

                          _op.productID = p.uuid;
                          _op.quantity = _sc.quantity;
                          _op.amount = _sc.quantity * p.currentPrice;
                          op.add(_op);
                        }

                        String storeID =
                            snapshot.data.documents.first.data['store_uuid'];
                        double sCharge =
                            await Store().getShippingCharge(storeID);

                        List<double> _priceDetails = [cPrice, oPrice, sCharge];
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                                true,
                                op,
                                _priceDetails,
                                storeID,
                                imagePaths,
                                writtenOrders),
                            settings: RouteSettings(name: '/orders'),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          "CHECKOUT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Georgia",
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
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

  Widget buildShoppingCartItem(BuildContext context, ShoppingCart sc) {
    return FutureBuilder<Products>(
      future: Products().getByProductID(sc.productID),
      builder: (BuildContext context, AsyncSnapshot<Products> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          Products _p = snapshot.data;
          child = Card(
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        width: 125,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 125,
                              height: 125,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: _p.getProductImage(),
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    fit: BoxFit.fill,
                                    image: imageProvider,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          valueColor: AlwaysStoppedAnimation(
                                              CustomColors.blue),
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
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width - 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${_p.name}',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Weight: ',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: "Georgia",
                                        color: CustomColors.lightBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '${_p.weight}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: CustomColors.black,
                                    fontFamily: "Georgia",
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    _p.getUnit(),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "Georgia",
                                      color: CustomColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Price: ',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: "Georgia",
                                        color: CustomColors.lightBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'Rs. ${_p.currentPrice}',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontFamily: "Georgia",
                                        fontSize: 16,
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FlatButton(
                                  child: Text(
                                    "Show Details",
                                    style: TextStyle(color: CustomColors.blue),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(_p),
                                        settings: RouteSettings(
                                            name: '/store/products'),
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
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: RaisedButton(
                              color: CustomColors.lightGrey,
                              onPressed: () async {
                                try {
                                  CustomDialogs.showLoadingDialog(
                                      context, _keyLoader);
                                  await ShoppingCart().removeItem(
                                      false, sc.storeID, sc.productID);
                                  Navigator.of(_keyLoader.currentContext,
                                          rootNavigator: true)
                                      .pop();
                                } catch (err) {
                                  print(err);
                                }
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CustomColors.alertRed,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            sc.quantity == 1.0
                                ? SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: OutlineButton(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Icon(Icons.delete_forever),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart().removeItem(
                                              false, sc.storeID, sc.productID);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
                                    ),
                                  )
                                : SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: OutlineButton(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Icon(Icons.remove),
                                      onPressed: () async {
                                        try {
                                          CustomDialogs.showLoadingDialog(
                                              context, _keyLoader);
                                          await ShoppingCart()
                                              .updateCartQuantityByID(
                                                  false, sc.uuid);
                                          Navigator.of(
                                                  _keyLoader.currentContext,
                                                  rootNavigator: true)
                                              .pop();
                                        } catch (err) {
                                          print(err);
                                        }
                                      },
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
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: OutlineButton(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(Icons.add),
                                onPressed: () async {
                                  try {
                                    CustomDialogs.showLoadingDialog(
                                        context, _keyLoader);
                                    await ShoppingCart()
                                        .updateCartQuantityByID(true, sc.uuid);
                                    Navigator.of(_keyLoader.currentContext,
                                            rootNavigator: true)
                                        .pop();
                                  } catch (err) {
                                    print(err);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Rs. ${_p.currentPrice * sc.quantity}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  fontSize: 16,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
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
  }
}

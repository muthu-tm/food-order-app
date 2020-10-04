import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/store/CartCounterWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../db/models/products.dart';
import '../utils/CustomColors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Products product;

  ProductDetailsScreen(this.product);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingCartScreen(),
                  settings: RouteSettings(name: '/cart'),
                ),
              );
            },
          ),
        ],
      ),
      body: getBody(context),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 11,
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    child: Divider(
                      color: Colors.black26,
                      height: 4,
                    ),
                    height: 24,
                  ),
                  widget.product.offer > 0
                      ? Text(
                          '₹ ${widget.product.originalPrice.toString()}',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough),
                        )
                      : Container(),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    '₹ ${widget.product.currentPrice.toString()}',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              SizedBox(
                width: 6,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoppingCartScreen(),
                      settings: RouteSettings(name: '/cart'),
                    ),
                  );
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.9,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        CustomColors.blueGreen,
                        CustomColors.green,
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                      ),
                      Text(
                        "Buy Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 150.0,
              width: double.infinity,
              child: Carousel(
                images: getImages(),
                dotSize: 5.0,
                dotSpacing: 20.0,
                dotColor: CustomColors.blue,
                indicatorBgPadding: 5.0,
                dotBgColor: CustomColors.black.withOpacity(0.2),
                borderRadius: true,
                radius: Radius.circular(20),
                noRadiusForIndicator: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Text(
                widget.product.name,
                style: TextStyle(
                    color: CustomColors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              color: CustomColors.grey,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.widgets,
                      size: 35,
                      color: CustomColors.blueGreen,
                    ),
                    title: Text(
                      "Quantity",
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      "${widget.product.weight} ${widget.product.getUnit()}",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  color: CustomColors.white),
                              child: Icon(
                                Icons.update,
                                size: 35,
                                color: Color(0xFFAB436B),
                              ),
                            ),
                            Text(
                              widget.product.isReturnable
                                  ? "Returnable"
                                  : "Not Returnable",
                              style: TextStyle(
                                  color: CustomColors.black,
                                  fontFamily: 'Georgia'),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  color: CustomColors.white),
                              child: Icon(
                                  widget.product.isDeliverable
                                      ? FontAwesomeIcons.shippingFast
                                      : Icons.transfer_within_a_station,
                                  size: 35,
                                  color: CustomColors.blue),
                            ),
                            Text(
                              widget.product.isDeliverable
                                  ? "Home Delivery"
                                  : "Self Pickup",
                              style: TextStyle(
                                  color: CustomColors.black,
                                  fontFamily: 'Georgia'),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  color: CustomColors.white),
                              child: Icon(
                                widget.product.isAvailable
                                    ? Icons.sentiment_very_satisfied
                                    : Icons.sentiment_dissatisfied,
                                size: 35,
                                color: widget.product.isAvailable
                                    ? CustomColors.green
                                    : CustomColors.alertRed,
                              ),
                            ),
                            Text(
                              widget.product.isAvailable
                                  ? "In Stock"
                                  : "Out Of Stock",
                              style: TextStyle(
                                  color: CustomColors.black,
                                  fontFamily: 'Georgia'),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              color: CustomColors.white,
              padding: EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      size: 35,
                      color: CustomColors.blueGreen,
                    ),
                    title: Text(
                      "Description",
                      style: TextStyle(
                          fontSize: 16,
                          color: CustomColors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia'),
                    ),
                  ),
                  ListTile(
                    leading: Text(""),
                    title: Text(
                      widget.product.shortDetails,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 14,
                          color: CustomColors.black,
                          fontFamily: 'Georgia'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CartCounter(widget.product.storeID, widget.product.uuid),
            ]),
          )
        ]),
      ),
    );
  }

  List<Widget> getImages() {
    List<Widget> images = [];

    for (var item in widget.product.getProductImages()) {
      images.add(
        CachedNetworkImage(
          imageUrl: item,
          imageBuilder: (context, imageProvider) => Image(
            height: 150,
            width: double.infinity,
            fit: BoxFit.contain,
            image: imageProvider,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
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
      );
    }
    return images;
  }
}

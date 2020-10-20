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

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

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
        FontAwesomeIcons.comments,
        size: 20,
      ),
      text: "Reviews",
    ),
    Tab(
      icon: Icon(
        FontAwesomeIcons.bookReader,
        size: 20,
      ),
      text: "FAQs",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: list.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart, color: CustomColors.black),
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
    );
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: 150.0,
                width: double.infinity,
                child: Carousel(
                  images: getImages(),
                  dotSize: 5.0,
                  dotSpacing: 20.0,
                  dotIncreasedColor: CustomColors.green,
                  dotColor: CustomColors.alertRed,
                  indicatorBgPadding: 1.0,
                  dotBgColor: Colors.transparent,
                  borderRadius: true,
                  radius: Radius.circular(20),
                  noRadiusForIndicator: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.product.shortDetails,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14,
                    color: CustomColors.black,
                    fontFamily: 'Georgia'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        "${widget.product.weight} ${widget.product.getUnit()}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
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
                      )
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      CartCounter(
                          widget.product.storeID, "", widget.product.uuid),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: CustomColors.white),
                            child: Icon(
                              Icons.update,
                              size: 30,
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
                            height: 30,
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
                                size: 30,
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
                            height: 30,
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
                              size: 30,
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
            Container(
              height: 200,
              child: TabBarView(controller: _controller, children: [
                Container(
                  child: Text("Details"),
                ),
                Container(),
                Container()
              ]),
            )
          ],
        ),
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

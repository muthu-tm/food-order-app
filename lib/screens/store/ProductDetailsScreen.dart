import 'package:chipchop_buyer/db/models/order_product.dart';
import 'package:chipchop_buyer/db/models/product_description.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/CheckoutScreen.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/orders/StoreOrderScreen.dart';
import 'package:chipchop_buyer/screens/store/CartCounterWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductFAQsWidget.dart';
import 'package:chipchop_buyer/screens/store/ProductReviewWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreProfileWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CarouselIndicatorSlider.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  String _variants = "0";
  Store store;

  TabController _controller;
  List<Widget> list = [
    Tab(
      text: "From Store",
    ),
    Tab(
      text: "Reviews",
    ),
    Tab(
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
      key: _scaffoldKey,
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
      body: SingleChildScrollView(child: getBody(context)),
      bottomNavigationBar: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 5.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreOrderScreen(
                          widget.product.storeID, widget.product.storeName),
                      settings: RouteSettings(name: '/cart'),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "View Cart",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () async {
                  try {
                    CustomDialogs.showLoadingDialog(context, _keyLoader);

                    List<ShoppingCart> _cartItems = await ShoppingCart()
                        .getCartForProduct(widget.product.storeID,
                            widget.product.uuid, _variants);

                    List<double> _priceDetails = [];
                    OrderProduct _op = OrderProduct();

                    double sCharge = await Store()
                        .getShippingChargeByID(widget.product.storeID);
                    double cPrice = 0.00;
                    double oPrice = 0.00;

                    if (_cartItems.isEmpty) {
                      cPrice = widget
                          .product.variants[int.parse(_variants)].currentPrice;
                      oPrice =
                          widget.product.variants[int.parse(_variants)].offer;
                      _priceDetails = [cPrice, oPrice, sCharge];

                      OrderProduct _op = OrderProduct();
                      _op.productID = widget.product.uuid;
                      _op.variantID = _variants;
                      _op.amount = widget
                          .product.variants[int.parse(_variants)].currentPrice;
                      _op.productName = widget.product.name;
                      _op.quantity = 1;
                    } else {
                      cPrice = _cartItems.first.quantity *
                          widget
                              .product
                              .variants[int.parse(_cartItems.first.variantID)]
                              .currentPrice;
                      oPrice = _cartItems.first.quantity *
                          widget
                              .product
                              .variants[int.parse(_cartItems.first.variantID)]
                              .offer;

                      _op.productID = widget.product.uuid;
                      _op.variantID = _cartItems.first.variantID;
                      _op.amount = _cartItems.first.quantity *
                          widget
                              .product
                              .variants[int.parse(_cartItems.first.variantID)]
                              .currentPrice;
                      _op.productName = widget.product.name;
                      _op.quantity = _cartItems.first.quantity;
                      _op.isReturnable = widget.product.isReturnable;

                      _priceDetails = [cPrice, oPrice, sCharge];
                    }

                    Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                        .pop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                            false,
                            [_op],
                            _priceDetails,
                            widget.product.storeID,
                            widget.product.storeName,
                            [],
                            ""),
                        settings: RouteSettings(name: '/products/checkout'),
                      ),
                    );
                  } catch (err) {
                    Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                        .pop();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(5.0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Buy Now",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: CarouselIndicatorSlider(widget.product.getProductImages()),
          ),
          widget.product.brandName != null &&
                  widget.product.brandName.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    widget.product.brandName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
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
          widget.product.shortDetails != null &&
                  widget.product.shortDetails.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    widget.product.shortDetails,
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomColors.black,
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                '₹ ${widget.product.variants[int.parse(_variants)].currentPrice.toString()}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 6,
              ),
              widget.product.variants[int.parse(_variants)].offer > 0
                  ? Text(
                      '₹ ${widget.product.variants[int.parse(_variants)].originalPrice.toString()}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (widget.product.variants.length == 1)
                    ? Container(
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : Container(
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        // dropdown below..
                        child: DropdownButton<String>(
                          value: _variants,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: CustomColors.green,
                          ),
                          iconSize: 30,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            setState(() {
                              _variants = newValue;
                            });
                          },
                          items: List.generate(widget.product.variants.length,
                              (int index) {
                            return DropdownMenuItem(
                              value: widget.product.variants[index].id,
                              child: Container(
                                child: Text(
                                  "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                                  style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                CartCounter(widget.product.storeID, widget.product.storeName,
                    widget.product.uuid, widget.product.name, _variants),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          widget.product.productDescription != null &&
                  widget.product.productDescription.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Card(
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: getProductDetails(),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: TabBar(
                indicator: BoxDecoration(color: Colors.blueAccent),
                labelColor: CustomColors.white,
                unselectedLabelColor: CustomColors.black,
                controller: _controller,
                tabs: list),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            child: TabBarView(
              controller: _controller,
              children: [
                Container(
                  child: getStoreDetails(context),
                ),
                SingleChildScrollView(
                  child: ProductReviewWidget(widget.product),
                ),
                SingleChildScrollView(
                    child: ProductFAQsWidget(widget.product.uuid)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getStoreDetails(BuildContext context) {
    return FutureBuilder(
      future: Store().getByID(widget.product.storeID),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            store = Store.fromJson(snapshot.data);
            return SingleChildScrollView(child: StoreProfileWidget(store));
          } else {
            return Container(
              padding: EdgeInsets.all(10),
              color: CustomColors.white,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                "Unable to load Store Details",
                style: TextStyle(
                  color: CustomColors.alertRed,
                  fontSize: 16.0,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
      },
    );
  }

  Widget getProductDetails() {
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.product.productDescription.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: CustomColors.grey,
        height: 0,
      ),
      itemBuilder: (BuildContext context, int index) {
        ProductDescription desc = widget.product.productDescription[index];
        return Container(
          padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              desc.images != null && desc.images.isNotEmpty
                  ? CarouselIndicatorSlider(desc.images)
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      desc.title,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      desc.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

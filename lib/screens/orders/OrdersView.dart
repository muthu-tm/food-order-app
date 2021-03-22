import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/order_written_details.dart';
import 'package:chipchop_buyer/db/models/product_reviews.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/orders/OrderAmountWidget.dart';
import 'package:chipchop_buyer/screens/orders/ProductReviewScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderViewScreen extends StatelessWidget {
  OrderViewScreen(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order : ${order.orderID}",
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
        child: Container(
          child: getBody(context),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        order.products.length > 0
            ? Column(
                children: [
                  ListTile(
                    title: Text("Ordered as Products"),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: order.products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: Products()
                            .getByProductID(order.products[index].productID),
                        builder: (context, AsyncSnapshot<Products> snapshot) {
                          Widget child;
                          if (snapshot.hasData) {
                            Products _p = snapshot.data;
                            child = Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 5, 5, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${_p.name}',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${_p.variants[int.parse(order.products[index].variantID)].weight}',
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: CustomColors.black,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                _p.variants[int.parse(order
                                                        .products[index]
                                                        .variantID)]
                                                    .getUnit(),
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: CustomColors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'X ${order.products[index].quantity.round()}',
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: CustomColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '₹ ${order.products[index].amount}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: CustomColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // if order not deliverred yet
                                    order.status != 5
                                        ? Align(
                                            alignment: Alignment.bottomRight,
                                            child: TextButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailsScreen(
                                                            _p),
                                                    settings: RouteSettings(
                                                        name:
                                                            '/store/products'),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Show Details",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color:
                                                        Colors.indigo.shade700),
                                              ),
                                              style: TextButton.styleFrom(
                                                  // splashColor: Colors.transparent,
                                                  // highlightColor:
                                                  //     Colors.transparent,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            children: <Widget>[
                                              Spacer(),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetailsScreen(
                                                              _p),
                                                      settings: RouteSettings(
                                                          name:
                                                              '/store/products'),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Show Details",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .indigo.shade700),
                                                ),
                                                style: TextButton.styleFrom(
                                                    // splashColor:
                                                    //     Colors.transparent,
                                                    // highlightColor:
                                                    //     Colors.transparent,
                                                    ),
                                              ),
                                              Spacer(),
                                              Container(
                                                height: 20,
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              Spacer(),
                                              TextButton(
                                                onPressed: () async {
                                                  bool reviewed =
                                                      await ProductReviews()
                                                          .reviewedProduct(
                                                              _p.uuid);

                                                  if (!reviewed) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductReviewScreen(
                                                                _p),
                                                        settings: RouteSettings(
                                                            name:
                                                                '/product/review'),
                                                      ),
                                                    );
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Reviewed this Product already!",
                                                        backgroundColor:
                                                            CustomColors
                                                                .alertRed,
                                                        textColor: CustomColors
                                                            .lightGrey);
                                                  }
                                                },
                                                child: Text(
                                                  "Add Review",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .indigo.shade700),
                                                ),
                                                style: TextButton.styleFrom(
                                                  // splashColor:
                                                  //     Colors.transparent,
                                                  // highlightColor:
                                                  //     Colors.transparent,
                                                ),
                                              ),
                                              Spacer(),
                                            ],
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
                ],
              )
            : Container(),
        order.capturedOrders.length > 0
            ? Column(
                children: [
                  ListTile(
                    title: Text("Ordered as Captured List"),
                  ),
                  SizedBox(
                    height: 175,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      primary: true,
                      shrinkWrap: true,
                      itemCount: order.capturedOrders.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageView(
                                        url: order.capturedOrders[index].image,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          order.capturedOrders[index].image,
                                      imageBuilder: (context, imageProvider) =>
                                          Image(
                                        fit: BoxFit.fill,
                                        height: 150,
                                        width: 150,
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
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      CustomColors.blue),
                                              strokeWidth: 2.0),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.error,
                                        size: 35,
                                      ),
                                      fadeOutDuration: Duration(seconds: 1),
                                      fadeInDuration: Duration(seconds: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                                "Price : ₹ ${order.capturedOrders[index].price}")
                          ],
                        );
                      },
                    ),
                  ),
                ],
              )
            : Container(),
        order.writtenOrders.isNotEmpty
            ? Column(
                children: [
                  ListTile(
                    title: Text("Ordered as Written List"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: CustomColors.grey),
                      child: ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: order.writtenOrders.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          color: CustomColors.white,
                          thickness: 2,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          WrittenOrders _wr = order.writtenOrders[index];

                          return Container(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Text(
                                  "Name : ",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                title: Text(
                                  '${_wr.name}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(color: CustomColors.black),
                                ),
                              ),
                              ListTile(
                                leading: Text(
                                  "Quantity : ",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${_wr.weight}',
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: CustomColors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            _wr.getUnit(),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: CustomColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'X ${_wr.quantity.round()}',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: Text(
                                  "Price : ",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                title: Text(
                                  '₹ ${_wr.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CustomColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ));
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: OrderAmountWidget(order),
        ),
      ],
    );
  }
}

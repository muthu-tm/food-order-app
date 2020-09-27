import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreProductWidget extends StatefulWidget {
  StoreProductWidget(this.storeID);

  final String storeID;
  @override
  _StoreProductWidgetState createState() => _StoreProductWidgetState();
}

class _StoreProductWidgetState extends State<StoreProductWidget> {
  Map<String, double> _cartMap = {};
  List<String> _wlMap = [];

  @override
  void initState() {
    super.initState();

    _loadCartDetails();
  }

  _loadCartDetails() async {
    try {
      List<ShoppingCart> cDetails =
          await ShoppingCart().fetchForStore(widget.storeID);

      for (var item in cDetails) {
        if (item.inWishlist)
          _wlMap.add(item.productID);
        else
          _cartMap[item.productID] = item.quantity;
      }

      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Products().streamAvailableProducts(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              children: List.generate(
                snapshot.data.documents.length,
                (index) {
                  Products product =
                      Products.fromJson(snapshot.data.documents[index].data);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product),
                          settings: RouteSettings(name: '/store/products'),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: CustomColors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Hero(
                                tag: "${product.uuid}",
                                child: CachedNetworkImage(
                                  imageUrl: product.getProductImage(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 100,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: imageProvider),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 35,
                                  ),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 2),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${product.weight} ${product.getUnit()}",
                                    style: TextStyle(
                                      color: CustomColors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Rs. ${product.originalPrice.toString()}",
                                    style: TextStyle(
                                      color: CustomColors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: CustomColors.blue,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _cartMap.containsKey(product.uuid)
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: OutlineButton(
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _cartMap[product.uuid] =
                                                      _cartMap[product.uuid] -
                                                          1.0;
                                                });
                                              },
                                              child: Icon(Icons.remove),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              _cartMap[product.uuid]
                                                  .toString()
                                                  .padLeft(2, "0"),
                                              style: TextStyle(
                                                  fontFamily: 'Georgia',
                                                  color: CustomColors.blue,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: OutlineButton(
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _cartMap[product.uuid] =
                                                      _cartMap[product.uuid] +
                                                          1.0;
                                                });
                                              },
                                              child: Icon(Icons.add),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Card(
                                      elevation: 2.0,
                                      color: CustomColors.lightGreen,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          iconSize: 20,
                                          alignment: Alignment.center,
                                          icon: Icon(Icons.add_shopping_cart),
                                          onPressed: () async {
                                            try {
                                              CustomDialogs.actionWaiting(
                                                  context);
                                              ShoppingCart wl = ShoppingCart();
                                              wl.storeID = widget.storeID;
                                              wl.productID = product.uuid;
                                              wl.inWishlist = false;
                                              wl.quantity = 1.0;
                                              wl.create();
                                              setState(() {
                                                _cartMap[product.uuid] = 1.0;
                                              });
                                              Navigator.pop(context);
                                            } catch (err) {
                                              print(err);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                              _wlMap.contains(product.uuid)
                                  ? Card(
                                      elevation: 2.0,
                                      color: CustomColors.green,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          iconSize: 20,
                                          alignment: Alignment.center,
                                          icon: Icon(
                                            Icons.favorite,
                                          ),
                                          onPressed: () async {
                                            try {
                                              CustomDialogs.actionWaiting(
                                                  context);
                                              await ShoppingCart().removeItem(
                                                  true,
                                                  widget.storeID,
                                                  product.uuid);
                                              setState(() {
                                                _wlMap.remove(product.uuid);
                                              });
                                              Navigator.pop(context);
                                            } catch (err) {
                                              print(err);
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                  : Card(
                                      elevation: 2.0,
                                      color: CustomColors.lightGrey,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          iconSize: 20,
                                          alignment: Alignment.center,
                                          icon: Icon(Icons.favorite_border),
                                          onPressed: () async {
                                            try {
                                              CustomDialogs.actionWaiting(
                                                  context);
                                              ShoppingCart wl = ShoppingCart();
                                              wl.storeID = widget.storeID;
                                              wl.productID = product.uuid;
                                              wl.inWishlist = true;
                                              wl.quantity = 1.0;
                                              wl.create();
                                              setState(() {
                                                _wlMap.add(product.uuid);
                                              });
                                              Navigator.pop(context);
                                            } catch (err) {
                                              print(err);
                                            }
                                          },
                                        ),
                                      ),
                                    )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            children = Container(
              height: 90,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    "No Product Available",
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                  Text(
                    "Sorry. Please Try Again Later!",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }

        return children;
      },
    );
  }
}

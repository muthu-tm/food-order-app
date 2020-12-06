import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StoreWishlistItems extends StatefulWidget {
  StoreWishlistItems(this.storeID, this.cartItems);

  final String storeID;
  final List<ShoppingCart> cartItems;
  @override
  _StoreWishlistItemsState createState() => _StoreWishlistItemsState();
}

class _StoreWishlistItemsState extends State<StoreWishlistItems> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Store().getByID(widget.storeID),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return Container();
          } else {
            Store store = Store.fromJson(snapshot.data);

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
                          Products _p = snapshot.data;

                          child = buildWishlistItem(context, _sc, _p);
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

  Widget buildWishlistItem(BuildContext context, ShoppingCart sc, Products _p) {
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
              width: MediaQuery.of(context).size.width - 140,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    ],
                  ),
                  SizedBox(
                    height: 5,
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
                              bool res = await ShoppingCart().moveToCart(
                                  sc.uuid,
                                  sc.storeID,
                                  sc.productID,
                                  sc.variantID);
                              Navigator.of(_keyLoader.currentContext,
                                      rootNavigator: true)
                                  .pop();

                              if (!res)
                                Fluttertoast.showToast(
                                    msg: 'This Product already in Your Cart !');
                            } catch (err) {
                              print(err);
                            }
                          },
                          child: Container(
                            height: 25,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.green[100]),
                            child: Text(
                              "Move To Cart",
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
                              await ShoppingCart().removeItem(
                                  true, sc.storeID, sc.productID, sc.variantID);
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
                                borderRadius: BorderRadius.circular(5),
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
}

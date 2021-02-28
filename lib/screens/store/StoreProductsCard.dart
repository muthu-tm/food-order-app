import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

class StoreProductsCard extends StatefulWidget {
  StoreProductsCard(this.product, this.cartMap, this.wlList);

  final Products product;
  final Map<String, double> cartMap;
  final List<String> wlList;

  @override
  _StoreProductsCardState createState() => _StoreProductsCardState();
}

class _StoreProductsCardState extends State<StoreProductsCard> {
  String _variant = "0";

  String getVariantID(String id) {
    return id.split("_")[1];
  }

  String getCartID() {
    return '${widget.product.uuid}_$_variant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          height: 90,
                          width: 110,
                          fit: BoxFit.fill,
                          imageUrl: widget.product.getProductImage(),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                            height: 90,
                            width: 110,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 90,
                            width: 110,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.error,
                              size: 35,
                            ),
                          ),
                          fadeOutDuration: Duration(seconds: 1),
                          fadeInDuration: Duration(seconds: 2),
                        ),
                      ),
                    ),
                    widget.product.variants.length > 1
                        ? InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.green[400],
                                )
                              ],
                            ),
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Container(
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: widget
                                                              .product
                                                              .getSmallProductImage(),
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Image(
                                                            fit: BoxFit.fill,
                                                            image:
                                                                imageProvider,
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
                                                                  valueColor: AlwaysStoppedAnimation(
                                                                      CustomColors
                                                                          .blue),
                                                                  strokeWidth:
                                                                      2.0),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.error,
                                                            size: 35,
                                                          ),
                                                          fadeOutDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          fadeInDuration:
                                                              Duration(
                                                                  seconds: 2),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              widget
                                                                  .product.name,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color:
                                                                      CustomColors
                                                                          .black,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          widget.product.brandName !=
                                                                      null &&
                                                                  widget
                                                                      .product
                                                                      .brandName
                                                                      .isNotEmpty
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10.0),
                                                                  child: Text(
                                                                    widget
                                                                        .product
                                                                        .brandName,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Choose Variant",
                                              style: TextStyle(
                                                  color: CustomColors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            ...widget.product.variants.map(
                                              (data) => RadioListTile(
                                                title: Text(
                                                    "${data.weight} ${data.getUnit()}"),
                                                secondary: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '₹ ${data.currentPrice.toString()}',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    data.offer > 0
                                                        ? Text(
                                                            '₹ ${data.originalPrice.toString()}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                value: data.id,
                                                groupValue: _variant,
                                                onChanged: (newValue) {
                                                  setState(
                                                    () {
                                                      _variant = newValue;
                                                    },
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                            child: Text(
                              "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.product.variants[int.parse(_variant)].offer > 0
                              ? Row(
                                  children: [
                                    Text(
                                      '₹ ${widget.product.variants[int.parse(_variant)].originalPrice.toString()}',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                )
                              : Container(),
                          Text(
                            '₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toString()}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.cartMap.containsKey(getCartID())
                            ? Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  height: 25,
                                  width: 73,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.lightBlue[100],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      widget.cartMap[getCartID()] == 1.0
                                          ? InkWell(
                                              onTap: () async {
                                                try {
                                                  CustomDialogs.actionWaiting(
                                                      context);
                                                  await ShoppingCart()
                                                      .removeItem(
                                                          false,
                                                          widget
                                                              .product.storeID,
                                                          widget.product.uuid,
                                                          _variant);
                                                  setState(() {
                                                    widget.cartMap
                                                        .remove(getCartID());
                                                  });
                                                  Navigator.pop(context);
                                                } catch (err) {
                                                  print(err);
                                                }
                                              },
                                              child: SizedBox(
                                                width: 23,
                                                height: 25,
                                                child: Icon(
                                                  Icons.delete_forever,
                                                  size: 15,
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                try {
                                                  CustomDialogs.actionWaiting(
                                                      context);
                                                  await ShoppingCart()
                                                      .updateCartQuantity(
                                                          false,
                                                          widget
                                                              .product.storeID,
                                                          widget.product.uuid,
                                                          _variant);
                                                  setState(() {
                                                    widget.cartMap[
                                                            getCartID()] =
                                                        widget.cartMap[
                                                                getCartID()] -
                                                            1.0;
                                                  });
                                                  Navigator.pop(context);
                                                } catch (err) {
                                                  print(err);
                                                }
                                              },
                                              child: SizedBox(
                                                width: 23,
                                                height: 25,
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: 3.0, left: 3.0),
                                        child: Text(
                                          widget.cartMap[getCartID()]
                                              .round()
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: CustomColors.blue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          try {
                                            CustomDialogs.actionWaiting(
                                                context);
                                            await ShoppingCart()
                                                .updateCartQuantity(
                                                    true,
                                                    widget.product.storeID,
                                                    widget.product.uuid,
                                                    _variant);
                                            setState(() {
                                              widget.cartMap[getCartID()] =
                                                  widget.cartMap[getCartID()] +
                                                      1.0;
                                            });
                                            Navigator.pop(context);
                                          } catch (err) {
                                            print(err);
                                          }
                                        },
                                        child: SizedBox(
                                          width: 23,
                                          height: 25,
                                          child: Icon(
                                            Icons.add,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    try {
                                      CustomDialogs.actionWaiting(context);
                                      ShoppingCart wl = ShoppingCart();
                                      wl.storeName = widget.product.storeName;
                                      wl.storeID = widget.product.storeID;
                                      wl.productID = widget.product.uuid;
                                      wl.productName = widget.product.name;
                                      wl.variantID = _variant;
                                      wl.inWishlist = false;
                                      wl.quantity = 1.0;
                                      await wl.create();
                                      setState(() {
                                        widget.cartMap[getCartID()] = 1.0;
                                      });
                                      Navigator.pop(context);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: Container(
                                    height: 25,
                                    width: 73,
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue[100],
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add,
                                            size: 15, color: Colors.black45),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            "ADD",
                                            style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        widget.wlList.contains(getCartID())
                            ? Card(
                                elevation: 3.0,
                                color: Colors.greenAccent[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    try {
                                      CustomDialogs.actionWaiting(context);
                                      await ShoppingCart().removeItem(
                                          true,
                                          widget.product.storeID,
                                          widget.product.uuid,
                                          _variant);
                                      setState(() {
                                        widget.wlList.remove(getCartID());
                                      });
                                      Navigator.pop(context);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: Container(
                                    height: 25,
                                    width: 73,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.remove,
                                            size: 15, color: Colors.grey),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.favorite,
                                              size: 18, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Card(
                                elevation: 3.0,
                                color: Colors.greenAccent[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    try {
                                      CustomDialogs.actionWaiting(context);
                                      ShoppingCart wl = ShoppingCart();
                                      wl.storeName = widget.product.storeName;
                                      wl.storeID = widget.product.storeID;
                                      wl.productID = widget.product.uuid;
                                      wl.productName = widget.product.name;
                                      wl.variantID = _variant;
                                      wl.inWishlist = true;
                                      wl.quantity = 1.0;
                                      await wl.create();
                                      setState(() {
                                        widget.wlList.add(getCartID());
                                      });
                                      Navigator.pop(context);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: Container(
                                    height: 25,
                                    width: 73,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add,
                                            size: 15, color: Colors.grey),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.favorite_border,
                                              size: 18, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "${widget.product.name}",
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}

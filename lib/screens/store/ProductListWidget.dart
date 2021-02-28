import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

class ProductListWidget extends StatefulWidget {
  ProductListWidget(this.product, this.cartMap);

  final Products product;
  final Map<String, double> cartMap;

  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
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
      height: 115,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  height: 100,
                  width: 100,
                  fit: BoxFit.fill,
                  imageUrl: widget.product.getProductImage(),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
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
          ),
          SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "${widget.product.name.trim()}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 75)
                  ],
                ),
                SizedBox(height: 5),
                widget.product.shortDetails.trim().isNotEmpty
                    ? Row(
                        children: [
                          Flexible(
                            child: Text(
                              "${widget.product.shortDetails.trim()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                          SizedBox(width: 75)
                        ],
                      )
                    : Container(),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.product.variants.length > 1
                        ? InkWell(
                            child: Row(
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
                                  color: Colors.redAccent,
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
                                                      '₹ ${data.currentPrice.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    data.offer > 0
                                                        ? Text(
                                                            '₹ ${data.originalPrice.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 12,
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
                        : Text(
                            "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0, 0, 3, 0),
                      child: Container(
                        width: 75,
                        child: widget.cartMap.containsKey(getCartID())
                            ? Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  height: 25,
                                  width: 75,
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
                                              fontSize: 13,
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
                                    width: 75,
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue[100],
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.product.variants[int.parse(_variant)].offer > 0
                              ? Flexible(
                                  child: Text(
                                    "₹ ${widget.product.variants[int.parse(_variant)].originalPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.black,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                )
                              : Container(),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                              child: Text(
                                "₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toStringAsFixed(2)}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.product.variants[int.parse(_variant)].offer > 0
                        ? Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(1.0, 0, 5, 0),
                              child: Text(
                                "You save ₹ ${widget.product.variants[int.parse(_variant)].offer} of total price ",
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 8.0,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
          // Container(
          //   width: 80,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       widget.wlList.contains(getCartID())
          //           ? Card(
          //               elevation: 3.0,
          //               color: Colors.greenAccent[100],
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(30.0),
          //               ),
          //               child: InkWell(
          //                 onTap: () async {
          //                   try {
          //                     CustomDialogs.actionWaiting(context);
          //                     await ShoppingCart().removeItem(
          //                         true,
          //                         widget.product.storeID,
          //                         widget.product.uuid,
          //                         _variant);
          //                     setState(() {
          //                       widget.wlList.remove(getCartID());
          //                     });
          //                     Navigator.pop(context);
          //                   } catch (err) {
          //                     print(err);
          //                   }
          //                 },
          //                 child: Container(
          //                   height: 30,
          //                   width: 70,
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       Icon(Icons.remove,
          //                           size: 20, color: Colors.grey),
          //                       Padding(
          //                         padding: EdgeInsets.all(5.0),
          //                         child: Icon(Icons.favorite,
          //                             size: 20, color: Colors.red),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             )
          //           : Card(
          //               elevation: 3.0,
          //               color: Colors.greenAccent[100],
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(30.0),
          //               ),
          //               child: InkWell(
          //                 onTap: () async {
          //                   try {
          //                     CustomDialogs.actionWaiting(context);
          //                     ShoppingCart wl = ShoppingCart();
          //                     wl.storeName = widget.product.storeName;
          //                     wl.storeID = widget.product.storeID;
          //                     wl.productID = widget.product.uuid;
          //                     wl.productName = widget.product.name;
          //                     wl.variantID = _variant;
          //                     wl.inWishlist = true;
          //                     wl.quantity = 1.0;
          //                     await wl.create();
          //                     setState(() {
          //                       widget.wlList.add(getCartID());
          //                     });
          //                     Navigator.pop(context);
          //                   } catch (err) {
          //                     print(err);
          //                   }
          //                 },
          //                 child: Container(
          //                   height: 30,
          //                   width: 70,
          //                   decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(30)),
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       Icon(Icons.add, size: 20, color: Colors.grey),
          //                       Padding(
          //                         padding: EdgeInsets.all(5.0),
          //                         child: Icon(Icons.favorite_border,
          //                             size: 20, color: Colors.red),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

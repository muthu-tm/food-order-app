import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

class StoreProductsCard extends StatefulWidget {
  StoreProductsCard(
      this.product, this.cartMap, this.cartsVarientsMap, this.wlList);

  final Products product;
  final Map<String, double> cartMap;
  final Map<String, List<String>> cartsVarientsMap;
  final List<String> wlList;

  @override
  _StoreProductsCardState createState() => _StoreProductsCardState();
}

class _StoreProductsCardState extends State<StoreProductsCard> {
  String _variant = "0";

  String getVarientID(String id) {
    return id.split("_")[1];
  }

  String getCartID() {
    return '${widget.product.uuid}_$_variant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.all(3),
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
              CachedNetworkImage(
                imageUrl: widget.product.getProductImage(),
                imageBuilder: (context, imageProvider) => Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    shape: BoxShape.rectangle,
                    image:
                        DecorationImage(fit: BoxFit.fill, image: imageProvider),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  size: 35,
                ),
                fadeOutDuration: Duration(seconds: 1),
                fadeInDuration: Duration(seconds: 2),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.product.variants.length > 1
                        ? Container(
                            height: 25,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            // dropdown below..
                            child: DropdownButton<String>(
                              value: _variant,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: CustomColors.green,
                              ),
                              iconSize: 30,
                              underline: SizedBox(),
                              onChanged: (String newValue) {
                                setState(() {
                                  _variant = newValue;
                                });
                              },
                              items: List.generate(
                                  widget.product.variants.length, (int index) {
                                return DropdownMenuItem(
                                  value: widget.product.variants[index].id,
                                  child: Container(
                                    child: Text(
                                      "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                                      style: TextStyle(
                                        color: CustomColors.black,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        : Container(
                            height: 25,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
                              style: TextStyle(
                                color: CustomColors.black,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                    Text(
                      " ₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toString()}",
                      style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 12.0,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          widget.product.brandName != null &&
                  widget.product.brandName.isNotEmpty
              ? Row(
                  children: [
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.product.brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.cartMap.containsKey(getCartID())
                  ? Container(
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue[100]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget.cartMap[getCartID()] == 1.0
                              ? InkWell(
                                  onTap: () async {
                                    try {
                                      CustomDialogs.actionWaiting(context);
                                      await ShoppingCart().removeItem(
                                          false,
                                          widget.product.storeID,
                                          widget.product.uuid,
                                          _variant);
                                      setState(() {
                                        widget.cartMap.remove(getCartID());
                                      });
                                      Navigator.pop(context);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Icon(Icons.delete_forever),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    try {
                                      CustomDialogs.actionWaiting(context);
                                      await ShoppingCart().updateCartQuantity(
                                          false,
                                          widget.product.storeID,
                                          widget.product.uuid,
                                          _variant);
                                      setState(() {
                                        widget.cartMap[getCartID()] =
                                            widget.cartMap[getCartID()] - 1.0;
                                      });
                                      Navigator.pop(context);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Icon(Icons.remove),
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0, left: 10.0),
                            child: Text(
                              widget.cartMap[getCartID()].round().toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: CustomColors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                CustomDialogs.actionWaiting(context);
                                await ShoppingCart().updateCartQuantity(
                                    true,
                                    widget.product.storeID,
                                    widget.product.uuid,
                                    _variant);
                                setState(() {
                                  widget.cartMap[getCartID()] =
                                      widget.cartMap[getCartID()] + 1.0;
                                });
                                Navigator.pop(context);
                              } catch (err) {
                                print(err);
                              }
                            },
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      color: Colors.greenAccent[100],
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
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20, color: Colors.green),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  "ADD",
                                  style: TextStyle(color: Colors.green),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
              widget.wlList.contains(getCartID())
                  ? Card(
                      color: Colors.blue[100],
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        height: 30,
                        width: 60,
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
                          child: Icon(Icons.favorite, color: Colors.blueAccent),
                        ),
                      ),
                    )
                  : Card(
                      color: Colors.blue[100],
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
                          height: 30,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  size: 20, color: Colors.blueAccent),
                              Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Icon(Icons.favorite,
                                    color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

class ProductWishlistWidget extends StatefulWidget {
  ProductWishlistWidget(this.storeID, this.productID);

  final String storeID;
  final String productID;

  @override
  _ProductWishlistWidgetState createState() => _ProductWishlistWidgetState();
}

class _ProductWishlistWidgetState extends State<ProductWishlistWidget> {
  Map<String, bool> _cartMap = {};
  Map<String, double> _cartQtyMap = {};

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
        _cartMap[item.productID] = item.inWishlist;
        _cartQtyMap[item.productID] = item.quantity;
      }

      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cartMap.containsKey(widget.productID)
        ? Container(
            child: IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () async {
                try {
                  CustomDialogs.actionWaiting(context);
                  await ShoppingCart()
                      .removeItem(true, widget.storeID, widget.productID);
                  Navigator.pop(context);
                } catch (err) {
                  print(err);
                }
              },
            ),
          )
        : Container(
            child: IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () async {
                try {
                  CustomDialogs.actionWaiting(context);
                  ShoppingCart wl = ShoppingCart();
                  wl.storeID = widget.storeID;
                  wl.productID = widget.productID;
                  wl.inWishlist = true;
                  wl.quantity = 1.0;
                  wl.create();
                  Navigator.pop(context);
                } catch (err) {
                  print(err);
                }
              },
            ),
          );
  }
}

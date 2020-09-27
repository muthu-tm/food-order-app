import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
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
    return FutureBuilder(
      future: ShoppingCart().checkWishlist(widget.storeID, widget.productID),
      builder: (BuildContext context, AsyncSnapshot<ShoppingCart> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            child = Container(
              child: IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
            );
          } else {
            child = Container(
              child: IconButton(
                  icon: Icon(Icons.favorite_border), onPressed: () {}),
            );
          }
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
  }
}

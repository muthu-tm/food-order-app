import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreProductsCard.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class CategoriesProductsWidget extends StatefulWidget {
  CategoriesProductsWidget(this.storeID, this.storeName, this.categoryID);

  final String storeID;
  final String storeName;
  final String categoryID;
  @override
  _CategoriesProductsWidgetState createState() =>
      _CategoriesProductsWidgetState();
}

class _CategoriesProductsWidgetState extends State<CategoriesProductsWidget> {
  Map<String, double> _cartMap = {};
  Map<String, List<String>> _cartsVarientsMap = {};
  List<String> _wlList = [];

  @override
  void initState() {
    super.initState();

    _loadCartDetails();
  }

  _loadCartDetails() async {
    try {
      Map<String, double> _tempMap = {};
      Map<String, List<String>> _tempCartsVarientsMap = {};
      List<String> _tempList = [];

      List<ShoppingCart> cDetails =
          await ShoppingCart().fetchForStore(widget.storeID);

      for (var item in cDetails) {
        if (item.inWishlist)
          _tempList.add(getCartID(item));
        else {
          _tempMap[getCartID(item)] = item.quantity;
          _tempCartsVarientsMap.update(getCartID(item), (value) {
            value.add(item.variantID);
            return value;
          }, ifAbsent: () => [item.variantID]);
        }
      }

      setState(() {
        _cartMap = _tempMap;
        _cartsVarientsMap = _tempCartsVarientsMap;
        _wlList = _tempList;
      });
    } catch (err) {
      print(err);
    }
  }

  String getCartID(ShoppingCart sc) {
    return '${sc.productID}_${sc.variantID}';
  }

  String getVarientID(String id) {
    return id.split("_")[1];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products()
          .getProductsForCategories([widget.storeID], widget.categoryID),
      builder: (BuildContext context, AsyncSnapshot<List<Products>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = Container(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                children: List.generate(
                  snapshot.data.length,
                  (index) {
                    Products product = snapshot.data[index];

                    return InkWell(
                      onTap: () {
                        UserActivityTracker _activity = UserActivityTracker();
                        _activity.keywords = "";
                        _activity.storeID = product.storeID;
                        _activity.productID = product.uuid;
                        _activity.productName = product.name;
                        _activity.refImage = product.getProductImage();
                        _activity.type = 2;
                        _activity.create();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(product),
                            settings: RouteSettings(name: '/store/products'),
                          ),
                        ).then((value) {
                          _loadCartDetails();
                        });
                      },
                      child: StoreProductsCard(
                          product, _cartMap, _cartsVarientsMap, _wlList),
                    );
                  },
                ),
              ),
            );
          } else {
            children = Container(
              padding: EdgeInsets.all(10),
              color: CustomColors.white,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                    "No Products added By Store",
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Worries!",
                    style: TextStyle(
                      color: CustomColors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You could still place Written/Captured ORDER here.",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 16.0,
                    ),
                  )
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

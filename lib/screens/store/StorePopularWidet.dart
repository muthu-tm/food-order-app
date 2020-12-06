import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreProductsCard.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class StorePopulartWidget extends StatefulWidget {
  StorePopulartWidget(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _StorePopulartWidgetState createState() => _StorePopulartWidgetState();
}

class _StorePopulartWidgetState extends State<StorePopulartWidget> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products().getPopularProducts([widget.storeID]),
      builder: (BuildContext context, AsyncSnapshot<List<Products>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = SliverStickyHeader(
              header: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Popular Products",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                color: Colors.white,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
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
                      );
                    },
                    child: StoreProductsCard(
                        product, _cartMap, _cartsVarientsMap, _wlList),
                  );
                }, childCount: snapshot.data.length),
              ),
            );
          } else {
            children = SliverStickyHeader(
              header: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Popular Products",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                color: Colors.white,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "No Popular Products added By Store",
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
                          "You could still order your favorite item with Written/Capture ORDER option!",
                          style: TextStyle(
                            color: CustomColors.blue,
                            fontSize: 16.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  childCount: 1,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          children = SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            ),
          );
        }

        return children;
      },
    );
  }
}

import 'package:chipchop_buyer/db/models/product_categories_map.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductListWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'ProductDetailsScreen.dart';
import 'StoreProductsCard.dart';

class StoreAllProductsWidget extends StatefulWidget {
  StoreAllProductsWidget(this.categories, this.storeID);

  final List<ProductCategoriesMap> categories;
  final String storeID;
  @override
  _StoreAllProductsWidgetState createState() => _StoreAllProductsWidgetState();
}

class _StoreAllProductsWidgetState extends State<StoreAllProductsWidget> {
  Map<String, double> _cartMap = {};
  List<String> _wlList = [];

  var _future;

  String _categoryID = "all products";
  bool isListView;

  @override
  void initState() {
    super.initState();
    isListView = true;
    _loadCartDetails();

    _future = Products().getProductsForStore(widget.storeID);
  }

  String getCartID(ShoppingCart sc) {
    return '${sc.productID}_${sc.variantID}';
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
        _wlList = _tempList;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 20, 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Available Products",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black)),
                    child: Row(children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isListView = !isListView;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(Icons.grid_view,
                              size: 20,
                              color: isListView ? Colors.black : Colors.cyan),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isListView = !isListView;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Icon(Icons.list,
                              size: 25,
                              color: isListView ? Colors.cyan : Colors.black),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
            color: Colors.white,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Row(
                      children: [
                        ActionChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black26),
                          ),
                          elevation: 3.0,
                          backgroundColor: _categoryID == "all products"
                              ? Colors.cyan[300]
                              : Colors.white,
                          onPressed: () {
                            setState(() {
                              _future = Products()
                                  .getProductsForStore(widget.storeID);
                              _categoryID = "all products";
                            });
                          },
                          labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                          label: Text(
                            "All",
                            style: TextStyle(
                                fontSize: 13,
                                color: _categoryID == "all products"
                                    ? Colors.black87
                                    : Colors.black54),
                          ),
                        ),
                        SizedBox(width: 10),
                        ActionChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black26),
                          ),
                          elevation: 3.0,
                          backgroundColor: _categoryID == "popular products"
                              ? Colors.cyan
                              : Colors.white,
                          onPressed: () {
                            setState(() {
                              _future = Products()
                                  .getPopularProducts([widget.storeID]);
                              _categoryID = "popular products";
                            });
                          },
                          label: Text(
                            "Popular Products",
                            style: TextStyle(
                                fontSize: 13,
                                color: _categoryID == "popular products"
                                    ? Colors.black87
                                    : Colors.black54),
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: const EdgeInsets.all(5.0),
                          child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.categories.length,
                            padding: EdgeInsets.all(5),
                            itemBuilder: (BuildContext context, int index) {
                              ProductCategoriesMap _sc =
                                  widget.categories[index];
                              return Padding(
                                padding: EdgeInsets.only(left: 5.0, right: 5),
                                child: ActionChip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.black26),
                                  ),
                                  elevation: 3.0,
                                  backgroundColor: _categoryID == _sc.uuid
                                      ? Colors.cyan
                                      : Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _future = Products()
                                          .getProductsForCategories(
                                              [widget.storeID], _sc.uuid);
                                      _categoryID = _sc.uuid;
                                    });
                                  },
                                  label: Text(
                                    _sc.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: _categoryID == _sc.uuid
                                            ? Colors.black87
                                            : Colors.black54),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<List<Products>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    height: 100,
                    child: Column(
                      children: AsyncWidgets.asyncWaiting(),
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Container(
                      height: 100,
                      child: Column(
                        children: AsyncWidgets.asyncError(),
                      ),
                    );
                  else if (snapshot.data.length == 0)
                    return Container(
                      height: 100,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Products added By Store",
                              style: TextStyle(
                                color: CustomColors.alertRed,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(height: 10),
                          ]),
                    );
                  else
                    return Card(
                      elevation: 3,
                      color: Colors.grey[100],
                      child: isListView
                          ? ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) => Divider(
                                        color: Colors.white,
                                      ),
                              padding: EdgeInsets.all(0),
                              primary: false,
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                Products product = snapshot.data[index];
                                return InkWell(
                                  onTap: () {
                                    UserActivityTracker _activity =
                                        UserActivityTracker();
                                    _activity.keywords = "";
                                    _activity.storeID = product.storeID;
                                    _activity.productID = product.uuid;
                                    _activity.productName = product.name;
                                    _activity.refImage =
                                        product.getProductImage();
                                    _activity.type = 2;
                                    _activity.create();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(product),
                                        settings: RouteSettings(
                                            name: '/store/products'),
                                      ),
                                    ).then((value) {
                                      _loadCartDetails();
                                    });
                                  },
                                  child: ProductListWidget(product, _cartMap),
                                );
                              })
                          : StaggeredGridView.countBuilder(
                              padding: EdgeInsets.all(0),
                              crossAxisCount: 2,
                              primary: false,
                              crossAxisSpacing: 0,
                              shrinkWrap: true,
                              mainAxisSpacing: 10,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                Products product = snapshot.data[index];

                                return InkWell(
                                  onTap: () {
                                    UserActivityTracker _activity =
                                        UserActivityTracker();
                                    _activity.keywords = "";
                                    _activity.storeID = product.storeID;
                                    _activity.productID = product.uuid;
                                    _activity.productName = product.name;
                                    _activity.refImage =
                                        product.getProductImage();
                                    _activity.type = 2;
                                    _activity.create();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(product),
                                        settings: RouteSettings(
                                            name: '/store/products'),
                                      ),
                                    ).then((value) {
                                      _loadCartDetails();
                                    });
                                  },
                                  child: StoreProductsCard(
                                      product, _cartMap, _wlList),
                                );
                              },
                              staggeredTileBuilder: (int index) =>
                                  StaggeredTile.fit(1),
                            ),
                    );
              }
            },
          )
        ],
      ),
    );
  }
}

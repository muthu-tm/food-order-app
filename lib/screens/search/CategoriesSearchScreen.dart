import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/shopping_cart.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductListWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class CategorySearchScreen extends StatefulWidget {
  final Map<String, String> id;
  final String storeFieldName;
  final String productFieldName;
  final String categoryName;
  final List<ProductSubCategories> subCats;

  CategorySearchScreen(this.id, this.storeFieldName, this.productFieldName,
      this.categoryName, this.subCats);

  @override
  _CategorySearchScreenState createState() => _CategorySearchScreenState();
}

class _CategorySearchScreenState extends State<CategorySearchScreen> {
  String queryField;
  String productQueryField;
  Map<String, String> valueMap;
  String _subCatID = "";

  bool isStoresView = true;

  Map<String, double> _cartMap = {};

  @override
  void initState() {
    super.initState();
    queryField = widget.storeFieldName;
    productQueryField = widget.productFieldName;

    valueMap = widget.id;

    _loadCartDetails();
  }

  String getCartID(ShoppingCart sc) {
    return '${sc.productID}_${sc.variantID}';
  }

  _loadCartDetails() async {
    try {
      Map<String, double> _tempMap = {};
      List<String> _tempList = [];

      List<ShoppingCart> cDetails = await ShoppingCart().fetchForUser();

      for (var item in cDetails) {
        if (item.inWishlist)
          _tempList.add(getCartID(item));
        else {
          _tempMap[getCartID(item)] = item.quantity;
        }
      }

      setState(() {
        _cartMap = _tempMap;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: CustomColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.categoryName}",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                              isStoresView = !isStoresView;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                "Stores",
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isStoresView ? Colors.cyan : Colors.black,
                                ),
                              ),
                            ),
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
                              isStoresView = !isStoresView;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                "Products",
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isStoresView ? Colors.black : Colors.cyan,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  ]),
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
                          widget.subCats.length > 0
                              ? ActionChip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.black26),
                                  ),
                                  elevation: 3.0,
                                  backgroundColor: _subCatID == ""
                                      ? Colors.cyan[300]
                                      : Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      queryField = "avail_product_categories";
                                      productQueryField = "product_category";
                                      valueMap = widget.id;
                                      _subCatID = "";
                                    });
                                  },
                                  labelPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  label: Text(
                                    "All",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: _subCatID == ""
                                            ? Colors.black87
                                            : Colors.black54),
                                  ),
                                )
                              : Container(),
                          widget.subCats.length > 0
                              ? Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(5.0),
                                  child: ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.subCats.length,
                                    padding: EdgeInsets.all(5),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      ProductSubCategories _sc =
                                          widget.subCats[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.0, right: 5),
                                        child: ActionChip(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Colors.black26),
                                          ),
                                          elevation: 3.0,
                                          backgroundColor: _subCatID == _sc.uuid
                                              ? Colors.cyan[200]
                                              : Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              queryField =
                                                  "avail_product_sub_categories";
                                              productQueryField =
                                                  "product_sub_category";
                                              valueMap = {
                                                'uuid': _sc.uuid,
                                                'name': _sc.name
                                              };
                                              _subCatID = _sc.uuid;
                                            });
                                          },
                                          label: Text(
                                            _sc.name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: _subCatID == _sc.uuid
                                                    ? Colors.black87
                                                    : Colors.black54),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isStoresView ? getListOfStores() : getListOfProducts()
          ],
        ),
      ),
    );
  }

  Widget getListOfStores() {
    return FutureBuilder(
      future: Store().getStoresByTypes(queryField, valueMap),
      builder: (context, AsyncSnapshot<List<Store>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            child = Container(
              height: 200,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sorry, No Stores Found !! ",
                    style: TextStyle(color: CustomColors.black),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.sentiment_dissatisfied)
                ],
              ),
            );
          } else {
            child = ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Store store = snapshot.data[index];

                return StoreWidget(store);
              },
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            ),
          );
        }
        return child;
      },
    );
  }

  Widget getListOfProducts() {
    return FutureBuilder(
      future: Products().getProductsByTypes(productQueryField, valueMap),
      builder: (context, AsyncSnapshot<List<Products>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            child = Container(
              height: 200,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sorry, No Products Found !! ",
                    style: TextStyle(color: CustomColors.black),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.sentiment_dissatisfied)
                ],
              ),
            );
          } else {
            child = ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
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
                  child: ProductListWidget(product, _cartMap),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

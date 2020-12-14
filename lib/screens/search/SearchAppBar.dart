import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/orders/OrderWidget.dart';
import 'package:chipchop_buyer/screens/search/RecentSearches.dart';
import 'package:chipchop_buyer/screens/search/SearchOptionsRadio.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreWidget.dart';
import 'package:chipchop_buyer/screens/store/VariantsWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  SearchAppBar(this.mode, this.searchKey);

  final int mode;
  final String searchKey;
  @override
  _SearchAppBarState createState() => new _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  int searchMode = 0;
  Future<List<Map<String, dynamic>>> snapshot;

  List<CustomRadioModel> inOutList = List<CustomRadioModel>();

  @override
  void initState() {
    super.initState();

    setState(() {
      searchMode = widget.mode;
    });

    inOutList.add(
      CustomRadioModel(widget.mode == 0, 'Store', ''),
    );
    inOutList.add(
      CustomRadioModel(widget.mode == 1, 'Product', ''),
    );
    inOutList.add(
      CustomRadioModel(widget.mode == 2, 'Order', ''),
    );

    if (widget.searchKey != "") {
      _searchController.text = widget.searchKey;
      _submit(widget.searchKey);
    }
  }

  _submit(String searchKey) {
    setState(
      () {
        searchMode == 0
            ? snapshot = Store().getStoreByName(searchKey)
            : searchMode == 1
                ? snapshot = Products().getByNameRange(searchKey)
                : snapshot = Order().getByOrderID(searchKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        centerTitle: true,
        titleSpacing: 0.0,
        title: TextFormField(
          controller: _searchController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            color: CustomColors.black,
          ),
          decoration: InputDecoration(
            hintText: searchMode == 0
                ? "Type Store Name"
                : searchMode == 1
                    ? "Type Product Name"
                    : "Type Order ID",
            hintStyle: TextStyle(color: CustomColors.black),
          ),
          onFieldSubmitted: (searchKey) {
            if (searchKey.trim().isEmpty || searchKey.trim().length < 2) {
              _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar("Enter minimum 2 digits", 2));
              return null;
            } else {
              _submit(searchKey);

              UserActivityTracker _activity = UserActivityTracker();
              _activity.keywords = searchKey;
              _activity.type = searchMode == 0
                  ? 3
                  : 4; // 3 - Store Search, 4 - product search
              _activity.create();
            }
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              size: 25.0,
              color: CustomColors.black,
            ),
            onPressed: () {
              setState(() {
                _searchController.text = "";
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              leading: InkWell(
                onTap: () {
                  searchMode = 0;
                  _searchController.text = '';

                  setState(
                    () {
                      inOutList[0].isSelected = true;
                      inOutList[1].isSelected = false;
                      inOutList[2].isSelected = false;
                    },
                  );
                },
                child: SearchOptionsRadio(inOutList[0], CustomColors.blueGreen),
              ),
              title: InkWell(
                onTap: () {
                  searchMode = 1;
                  _searchController.text = '';

                  setState(
                    () {
                      inOutList[0].isSelected = false;
                      inOutList[1].isSelected = true;
                      inOutList[2].isSelected = false;
                    },
                  );
                },
                child: SearchOptionsRadio(inOutList[1], CustomColors.blue),
              ),
              trailing: InkWell(
                onTap: () {
                  searchMode = 2;
                  _searchController.text = '';

                  setState(
                    () {
                      inOutList[0].isSelected = false;
                      inOutList[1].isSelected = false;
                      inOutList[2].isSelected = true;
                    },
                  );
                },
                child: SearchOptionsRadio(inOutList[2], CustomColors.grey),
              ),
            ),
            Divider(),
            FutureBuilder(
              future: snapshot,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    _searchController.text != '') {
                  if (snapshot.data.isNotEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (inOutList[0].isSelected == true) {
                          return StoreWidget(
                              Store.fromJson(snapshot.data[index]));
                        } else if (inOutList[1].isSelected == true) {
                          Products product =
                              Products.fromJson(snapshot.data[index]);
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: CustomColors.white,
                              ),
                              child: ListTile(
                                onTap: () async {
                                  Products _product = await Products()
                                      .getByProductID(product.uuid);

                                  UserActivityTracker _activity =
                                      UserActivityTracker();
                                  _activity.keywords = "";
                                  _activity.storeID = _product.storeID;
                                  _activity.productID = _product.uuid;
                                  _activity.productName = _product.name;
                                  _activity.refImage =
                                      _product.getProductImage();
                                  _activity.type = 2;
                                  _activity.create();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(_product),
                                      settings: RouteSettings(
                                          name: '/settings/products/view'),
                                    ),
                                  );
                                },
                                leading: CachedNetworkImage(
                                  imageUrl: product.getProductImage(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 60,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: imageProvider),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 35,
                                  ),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 2),
                                ),
                                title: Text(
                                  product.name,
                                  style: TextStyle(
                                    color: CustomColors.blue,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: ProductVariantsWidget(product, 0),
                              ),
                            ),
                          );
                        } else {
                          return OrderWidget(
                              Order.fromJson(snapshot.data[index]));
                        }
                      },
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          inOutList[0].isSelected == true
                              ? "No Stores Found"
                              : inOutList[1].isSelected == true
                                  ? "No Products Found"
                                  : "No Orders Found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        Text(
                          "Try with different KEYWORDS..",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CustomColors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncError(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncWaiting(),
                  );
                } else {
                  return UserRecentSearches();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

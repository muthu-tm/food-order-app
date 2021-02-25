import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/RecentProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/VariantsWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreSearchBar extends StatefulWidget {
  StoreSearchBar(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _StoreSearchBarState createState() => new _StoreSearchBarState();
}

class _StoreSearchBarState extends State<StoreSearchBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>> snapshot;

  @override
  void initState() {
    super.initState();
  }

  void _submit(String key) {
    setState(() {
      snapshot = Products().getByNameForStore(key, widget.storeID);
    });
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
          onFieldSubmitted: (searchKey) {
            if (searchKey.trim().isNotEmpty) {
              UserActivityTracker _activity = UserActivityTracker();
              _activity.keywords = searchKey;
              _activity.type = 4; // 4 - product search
              _activity.create();

              _submit(searchKey);
            }
          },
          decoration: InputDecoration(
            hintText: "Type Keyword",
            hintStyle: TextStyle(color: CustomColors.black),
          ),
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
              color: CustomColors.alertRed,
            ),
            onPressed: () async {
              setState(() {
                _searchController.text = "";
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: snapshot,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    _searchController.text != '') {
                  if (snapshot.data.isNotEmpty) {
                    return Column(children: [
                      ListTile(
                        title: Text(
                          "Your search results",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
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
                        },
                      ),
                    ]);
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Items found !!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CustomColors.alertRed,
                                    fontSize: 15,
                                  ),
                                ),
                                Icon(
                                  Icons.sentiment_neutral,
                                  size: 30,
                                  color: CustomColors.alertRed,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Search for another Items",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CustomColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
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
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: AsyncWidgets.asyncSearching(),
                    ),
                  );
                } else {
                  return RecentProductsWidget(widget.storeID);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

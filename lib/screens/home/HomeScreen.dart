import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/db/models/users_shopping_details.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductWidget.dart';
import 'package:chipchop_buyer/screens/store/RecentProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/RecentStoresWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int backPressCounter = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> onWillPop() {
    if (backPressCounter < 1) {
      backPressCounter++;
      Fluttertoast.showToast(msg: "Press again to exit !!");
      Future.delayed(Duration(seconds: 2, milliseconds: 0), () {
        backPressCounter--;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: appBar(context),
        drawer: sideDrawer(context),
        backgroundColor: CustomColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: SearchBarWidget(),
              ),
              //getBanners(),
              ListTile(
                title: Text(
                  "Top Categories",
                  style: TextStyle(
                      color: CustomColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: getCategoryCards(context),
              ),
              RecentStoresWidget(),
              getPopularProducts(context),
              RecentProductsWidget(''),
              getFrequentlyShoppedProducts(context),
            ],
          ),
        ),
        bottomNavigationBar: bottomBar(context),
      ),
    );
  }

  Widget getBanners() {
    return Container();
  }

  Widget getFrequentlyShoppedProducts(BuildContext context) {
    return FutureBuilder(
      future: UserShoppingDetails().getFrequentlyShopped(),
      builder: (context, AsyncSnapshot<List<UserShoppingDetails>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    "Frequently Shopped",
                    style: TextStyle(
                        color: CustomColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    height: 160,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        primary: true,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        padding: EdgeInsets.all(5),
                        itemBuilder: (BuildContext context, int index) {
                          UserShoppingDetails _sd = snapshot.data[index];
                          return Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Container(
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () async {
                                  CustomDialogs.actionWaiting(context);
                                  Products _p = await Products()
                                      .getByProductID(_sd.productID);

                                  UserActivityTracker _activity =
                                      UserActivityTracker();
                                  _activity.keywords = "";
                                  _activity.storeID = _sd.storeID;
                                  _activity.productID = _sd.productID;
                                  _activity.productName = _p.name;
                                  _activity.refImage = _p.getProductImage();
                                  _activity.type = 2;
                                  _activity.create();

                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(_p),
                                      settings: RouteSettings(
                                          name: '/store/products'),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: FutureBuilder(
                                        future: Products()
                                            .getByProductID(_sd.productID),
                                        builder: (context,
                                            AsyncSnapshot<Products> snapshot) {
                                          if (snapshot.hasData) {
                                            return CachedNetworkImage(
                                              imageUrl: snapshot.data
                                                  .getProductImage(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 130,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: imageProvider),
                                                ),
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                size: 35,
                                              ),
                                              fadeOutDuration:
                                                  Duration(seconds: 1),
                                              fadeInDuration:
                                                  Duration(seconds: 2),
                                            );
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        _sd.productName,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: CustomColors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget getPopularProducts(BuildContext context) {
    return FutureBuilder(
        future: Store().streamFavStores(cachedLocalUser.primaryLocation),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          Widget child;
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              List<String> storeIDs = [];
              for (var store in snapshot.data) {
                storeIDs.add(store.uuid);
              }
              child = FutureBuilder(
                  future: Products().getPopularProducts(storeIDs),
                  builder: (context, AsyncSnapshot<List<Products>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.isEmpty) {
                        return Container();
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                "Popular Products",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                height: 160,
                                child: Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      primary: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.length,
                                      padding: EdgeInsets.all(5),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ProductWidget(
                                          snapshot.data[index],
                                        );
                                      }),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      return Container();
                    }
                  });
            } else {
              child = Container();
            }
          } else if (snapshot.hasError) {
            child = Container();
          } else {
            child = Container();
          }
          return child;
        });
  }

  Widget getCategoryCards(BuildContext context) {
    List<Color> colors = [
      CustomColors.alertRed,
      CustomColors.green,
      CustomColors.blue,
      CustomColors.purple,
      CustomColors.orange,
      CustomColors.blueGreen
    ];
    return FutureBuilder(
      future: ProductTypes().getDashboardTypes(),
      builder: (context, AsyncSnapshot<List<ProductTypes>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              shrinkWrap: true,
              primary: false,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(1.0),
              children: List<Widget>.generate(
                snapshot.data.length,
                (index) {
                  ProductTypes types = snapshot.data[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListOfTopCategoryStores(types.uuid, types.name),
                          settings: RouteSettings(name: '/home/categories'),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        gradient: LinearGradient(
                            colors: [
                              CustomColors.black.withOpacity(0.8),
                              colors[index % colors.length]
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              types.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: CustomColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  FontAwesomeIcons.arrowAltCircleRight,
                                  size: 25,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(10),
              color: CustomColors.white,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                "Unable to load Top Categories",
                style: TextStyle(
                  color: CustomColors.alertRed,
                  fontSize: 16.0,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
      },
    );
  }

  Widget getTrendingProducts(BuildContext context) {
    return Column();
  }
}

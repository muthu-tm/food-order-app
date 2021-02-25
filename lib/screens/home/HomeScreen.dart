import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/chat_temp.dart';
import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/db/models/users_shopping_details.dart';
import 'package:chipchop_buyer/main.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/chats/ChatsHome.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrderDetailsScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_buyer/screens/search/SearchByCategoriesScreen.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/search/search_home.dart';
import 'package:chipchop_buyer/screens/settings/SettingsHome.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/ProductWidget.dart';
import 'package:chipchop_buyer/screens/store/RecentProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/RecentStoresWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

bool newStoreNotification = false;
bool newOrderNotification = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  Map<String, dynamic> msg = event.data;

  switch (msg['screen']) {
    case "store-chat":
      navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) => StoreChatScreen(
            storeID: msg['store_uuid'], storeName: msg['store_name']),
        settings: RouteSettings(name: '/chats/store'),
      ));
      break;
    case "order":
      navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) =>
            OrderDetailsScreen(msg['order_id'], msg['order_uuid']),
        settings: RouteSettings(name: '/orders/details'),
      ));
      break;
    case "product":
      Products _p = await Products().getByProductID(msg['product_id']);
      if (_p != null) {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(_p),
          settings: RouteSettings(name: '/store/products'),
        ));
      }
      break;
  }

  if (msg['type'] == '100') {
    await ChatTemplate().updateToUnRead(msg['store_uuid']);

    newStoreNotification = true;
  } else if (msg['type'] == '000' || msg['type'] == '001') {
    // Order update || Order chat
    newOrderNotification = true;
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen(this.index);

  final int index;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _newStoreNotification = false;
  bool _newOrderNotification = false;

  int backPressCounter = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;

    _newStoreNotification = newStoreNotification;
    _newOrderNotification = newOrderNotification;

    FirebaseMessaging.onMessage.listen((event) async {
      Map<String, dynamic> message = event.data;

      if (message['type'] == '100') {
        await ChatTemplate().updateToUnRead(message['store_uuid']);
        setState(() {
          _newStoreNotification = true;
          newStoreNotification = true;
        });
      } else if (message['type'] == '000' || message['type'] == '001') {
        // Order update || Order chat
        setState(() {
          _newOrderNotification = true;
          newOrderNotification = true;
        });
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      Map<String, dynamic> message = event.data;

      if (message['type'] == '100') {
        await ChatTemplate().updateToUnRead(message['store_uuid']);

        setState(() {
          _newStoreNotification = true;
          newStoreNotification = true;
        });
      } else if (message['type'] == '000' || message['type'] == '001') {
        // Order update || Order chat
        setState(() {
          _newOrderNotification = true;
          newOrderNotification = true;
        });
      }
      print("onLaunch: $message");
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    Size size = Size((MediaQuery.of(context).size.width / 5), 100);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: appBar(context),
        drawer: sideDrawer(context),
        backgroundColor: CustomColors.lightGrey,
        body: SingleChildScrollView(
          child: _selectedIndex == 0
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                      child: SearchBarWidget(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(children: [
                          ListTile(
                            title: Text(
                              "Top Categories",
                              style: TextStyle(
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: getCategoryCards(context),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchByCategoriesScreen(),
                                  settings:
                                      RouteSettings(name: '/search/categories'),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.grid_view,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "More Categories",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    RecentStoresWidget(),
                    getPopularProducts(context),
                    RecentProductsWidget(''),
                    getFrequentlyShoppedProducts(context),
                  ],
                )
              : _selectedIndex == 1
                  ? SearchHome()
                  : _selectedIndex == 2
                      ? ChatsHome()
                      : _selectedIndex == 3
                          ? OrdersHomeScreen()
                          : SettingsHome(),
        ),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [CustomColors.white, CustomColors.green],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(0);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        size: 25.0,
                        color: CustomColors.black,
                      ),
                      Text("Home", style: GoogleFonts.orienta()),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(1);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: CustomColors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.search,
                          size: 16.0,
                          color: CustomColors.white,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text("Search", style: GoogleFonts.orienta()),
                    ],
                  ),
                ),
              ),
              _newStoreNotification
                  ? SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _newStoreNotification = false;
                            _selectedIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.question_answer,
                                    size: 22.0,
                                    color: CustomColors.black,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: CustomColors.alertRed,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 10,
                                        minHeight: 10,
                                      ),
                                    ),
                                  )
                                ]),
                            SizedBox(
                              height: 3,
                            ),
                            Text("Chats",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _newStoreNotification = false;
                            _selectedIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.question_answer,
                              size: 22.0,
                              color: CustomColors.black,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text("Chats", style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    ),
              _newOrderNotification
                  ? SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newOrderNotification = false;
                            _newOrderNotification = false;

                            _selectedIndex = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.shoppingBag,
                                    size: 22.0,
                                    color: CustomColors.black,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: CustomColors.alertRed,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 11,
                                        minHeight: 11,
                                      ),
                                    ),
                                  )
                                ]),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Orders", style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newOrderNotification = false;
                            _newOrderNotification = false;

                            _selectedIndex = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.shoppingBag,
                              size: 22.0,
                              color: CustomColors.black,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Orders", style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    ),
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(4);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        size: 22.0,
                        color: CustomColors.black,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        "Settings",
                        style: GoogleFonts.orienta(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                        fontSize: 14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    height: 160,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
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

                                  if (_p == null) {
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg: 'Error, Unable to Load Product!',
                                        backgroundColor: CustomColors.alertRed,
                                        textColor: CustomColors.white);
                                    return;
                                  }

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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                    fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                height: 160,
                                child: Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                          builder: (context) => ListOfTopCategoryStores(
                              {'uuid': types.uuid, 'name': types.name},
                              'avail_products',
                              types.name),
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
              width: MediaQuery.of(context).size.width,
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
}

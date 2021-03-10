import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_store_wallet_history.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/orders/StoreOrderScreen.dart';
import 'package:chipchop_buyer/screens/search/StoreSearchBar.dart';
import 'package:chipchop_buyer/screens/store/StoreAllProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoryWidget.dart';
import 'package:chipchop_buyer/screens/store/TopSellingProductsWidget.dart';
import 'package:chipchop_buyer/screens/utils/CarouselIndicatorSlider.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/CustomColors.dart';

class ViewStoreScreen extends StatefulWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  _ViewStoreScreenState createState() => _ViewStoreScreenState();
}

class _ViewStoreScreenState extends State<ViewStoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  final Map<String, String> tempCollectionDays = {
    "0": "Sun",
    "1": "Mon",
    "2": "Tue",
    "3": "Wed",
    "4": "Thu",
    "5": "Fri",
    "6": "Sat",
  };

  int selectedItem = 1;
  bool isWithinWorkingHours;
  bool businessHours;
  bool businessDays;
  var currentTime;

  Customers _cust;
  double dist;

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    businessHours = (currentTime.isAfter(
            DateUtils.getTimeAsDateTimeObject(widget.store.activeFrom)) &&
        currentTime.isBefore(
            DateUtils.getTimeAsDateTimeObject(widget.store.activeTill)));
    businessDays = (DateTime.now().weekday <= 6
        ? widget.store.workingDays.contains(DateTime.now().weekday)
        : widget.store.workingDays.contains(0));
    isWithinWorkingHours = businessHours && businessDays;

    widget.store.getUserDistance().then((value) => dist = value);

    UserStoreWalletHistory().getStoreCustomer(widget.store.uuid).then((value) {
      setState(() {
        _cust = value;
      });
    });
  }

  Widget flexibleAppBar(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top + 50;

    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.store.address.street +
                        ', ' +
                        widget.store.address.city,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Row(
                    children: [
                      dist != null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.assistant_navigation,
                                  size: 13,
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    '${dist.toStringAsFixed(2)} km',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )
                          : Container(),
                      Row(
                        children: [
                          Icon(
                            Icons.local_taxi_outlined,
                            size: 13,
                            color: Colors.red,
                          ),
                          Text(
                            " ₹ ${widget.store.deliveryDetails.deliveryCharges02.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Need Help? Contact Store!",
                          style: TextStyle(fontSize: 8, color: Colors.black),
                        ),
                        InkWell(
                          onTap: () async {
                            await showDialog(
                                context: _scaffoldKey.currentContext,
                                builder: (context) {
                                  return storeDialog();
                                });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, left: 5.0),
                            child: Text(
                              "More about store!",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.redAccent,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        InkWell(
                          onTap: isWithinWorkingHours
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoreChatScreen(
                                        storeID: widget.store.uuid,
                                        storeName: widget.store.name,
                                      ),
                                      settings:
                                          RouteSettings(name: '/store/chat'),
                                    ),
                                  );
                                }
                              : () {
                                  Fluttertoast.showToast(
                                      msg: 'Store is closed');
                                },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.150,
                              height: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Chat",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: CustomColors.black),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: isWithinWorkingHours
                                    ? Colors.cyanAccent[400]
                                    : Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: isWithinWorkingHours
                                ? () async {
                                    await UrlLauncherUtils.makePhoneCall(widget
                                        .store.contacts.first.contactNumber);
                                  }
                                : () {
                                    Fluttertoast.showToast(
                                        msg: 'Store is closed');
                                  },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.150,
                                height: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 8,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Call",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: CustomColors.black),
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: isWithinWorkingHours
                                      ? Colors.amber[200]
                                      : Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (businessDays &&
                                    currentTime.isBefore(
                                        DateUtils.getTimeAsDateTimeObject(
                                            widget.store.activeFrom)))
                                ? Text(
                                    "Opening in ${currentTime.difference(DateUtils.getTimeAsDateTimeObject(widget.store.activeFrom)).abs().toString().substring(0, 4)} hours",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: CustomColors.black),
                                  )
                                : isWithinWorkingHours
                                    ? Text(
                                        "Closing in ${DateUtils.durationInMinutesToHoursAndMinutes(DateUtils.getTimeInMinutes(widget.store.activeTill) - DateUtils.getCurrentTimeInMinutes())} hours",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: CustomColors.alertRed),
                                      )
                                    : Text(
                                        "Store Closed",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: CustomColors.alertRed),
                                      ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  child: Image.asset(
                    "images/store_assured.png",
                    height: 40,
                    width: 100,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 220,
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.orange[200],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              _cust != null
                                  ? "Wallet Balance : ₹ ${_cust.availableBalance}"
                                  : "Wallet Balance : ₹ 0.00",
                              style: TextStyle(fontSize: 7),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.pink[100],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              "Free delivery above ₹ ${widget.store.deliveryDetails.freeDelivery ?? '--'}",
                              style: TextStyle(fontSize: 7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Container(
                        width: 215,
                        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.teal[200],
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Text(
                          "Combo Offers & Promo code : Coming Soon..",
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget fixedAppBar(BuildContext context) {
    return Text(
      widget.store.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        reverse: false,
        slivers: [
          SliverAppBar(
            title: fixedAppBar(context),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            leadingWidth: 25,
            pinned: true,
            floating: true,
            backgroundColor: CustomColors.green,
            expandedHeight: 185.0,
            flexibleSpace: FlexibleSpaceBar(
              background: flexibleAppBar(context),
            ),
          ),
          SliverToBoxAdapter(
            child: widget.store.notice.trim().isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.store.notice,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
          SliverPersistentHeader(
            delegate: SearchBar(widget.store),
            pinned: true,
          ),
          StoreCategoryWidget(widget.store),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          TopSellingProductsWidget(widget.store.uuid, widget.store.name),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          StoreAllProductsWidget(
              widget.store.availProductCategories, widget.store.uuid),
          // StorePopulartWidget(widget.store.uuid, widget.store.name),
          // SliverToBoxAdapter(
          //   child: SizedBox(
          //     height: 25,
          //   ),
          // ),
          // StoreProductWidget(widget.store.uuid, widget.store.name),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoppingCartScreen(),
                      settings: RouteSettings(name: '/cart'),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  color: Colors.orangeAccent[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  borderOnForeground: true,
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_sharp,
                              size: 11,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Go to Cart",
                            style: TextStyle(fontSize: 10),
                          )
                        ]),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreOrderScreen(
                        widget.store.uuid,
                        widget.store.name,
                      ),
                      settings: RouteSettings(name: '/store/checkout'),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  color: Colors.lightGreenAccent[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.lightGreenAccent[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.shopping_bag,
                              size: 11,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Buy Now",
                            style: TextStyle(fontSize: 10),
                          )
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget storeDialog() {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.store.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  widget.store.shortDetails.isNotEmpty
                      ? Flexible(
                          child: Text(
                          widget.store.shortDetails,
                          maxLines: 2,
                          style: TextStyle(fontSize: 10),
                        ))
                      : Container(),
                  SizedBox(
                    height: 5,
                  ),
                  widget.store.address.street.isNotEmpty
                      ? Flexible(
                          child: Text(
                            widget.store.address.street,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      : Container(),
                  widget.store.address.city.isNotEmpty
                      ? Flexible(
                          child: Text(
                            "${widget.store.address.city}, ${widget.store.address.pincode}",
                            maxLines: 1,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    spacing: 3,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (widget.store.deliveryDetails.availableOptions
                          .contains(0))
                        Card(
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.greenAccent[100],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Pick-up from store",
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      if (widget.store.deliveryDetails.availableOptions
                          .contains(1))
                        Card(
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow[200],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Instant delivery",
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      if (widget.store.deliveryDetails.availableOptions
                          .contains(2))
                        Card(
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent[100],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Standard delivery",
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      if (widget.store.deliveryDetails.availableOptions
                          .contains(3))
                        Card(
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[200],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Scheduled delivery",
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CarouselIndicatorSlider(widget.store.storeImages,
                      height: MediaQuery.of(context).size.height * 0.25,
                      bg: Colors.grey[500]),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.date_range,
                          size: 18,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Business / Working Days",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: selectedDays.toList(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.alarm_on_rounded),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Business / Working Time",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateUtils.getFormattedTime(widget.store.activeFrom),
                        ),
                      ),
                      Text("-"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateUtils.getFormattedTime(widget.store.activeTill),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.local_taxi_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Delivery Time",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(DateUtils.getFormattedTime(
                            widget.store.deliveryDetails.deliveryFrom)),
                      ),
                      Text("-"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(DateUtils.getFormattedTime(
                            widget.store.deliveryDetails.deliveryTill)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> get selectedDays sync* {
    List workingDays = [];
    widget.store.workingDays.forEach((element) {
      if (tempCollectionDays.keys.contains(element.toString())) {
        workingDays.add(tempCollectionDays[element.toString()]);
      }
    });
    yield Text(workingDays.join(", "));
  }
}

class SearchBar extends SliverPersistentHeaderDelegate {
  final Store store;

  SearchBar(this.store);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreSearchBar(store.uuid, store.name),
                ),
              );
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: CustomColors.white),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 12,
                      color: CustomColors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      "Search for an item",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Georgia",
                          color: CustomColors.grey),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 70.0;

  @override
  double get minExtent => 65.0;
}

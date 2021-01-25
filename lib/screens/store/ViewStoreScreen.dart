import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/orders/StoreOrderScreen.dart';
import 'package:chipchop_buyer/screens/search/StoreSearchBar.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoryWidget.dart';
import 'package:chipchop_buyer/screens/store/StorePopularWidet.dart';
import 'package:chipchop_buyer/screens/store/StoreProductsWidget.dart';
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
  }

  Widget flexibleAppBar(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Container(
        padding: new EdgeInsets.only(top: statusBarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.store.address.street + ', ' + widget.store.address.city,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (businessDays &&
                        currentTime.isBefore(DateUtils.getTimeAsDateTimeObject(
                            widget.store.activeFrom)))
                    ? Text(
                        "Opening in ${currentTime.difference(DateUtils.getTimeAsDateTimeObject(widget.store.activeFrom)).abs().toString().substring(0, 4)} hours")
                    : isWithinWorkingHours
                        ? Text(
                            "Closing in ${DateUtils.durationInMinutesToHoursAndMinutes(DateUtils.getTimeInMinutes(widget.store.activeTill) - DateUtils.getCurrentTimeInMinutes())} hours",
                            style: TextStyle(color: CustomColors.alertRed),
                          )
                        : Text("Store Closed"),
              ],
            ),
            Text(
              "Minimum delivery charge \u20B9 ${widget.store.deliveryDetails.deliveryCharges02.toString()}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Row(
              children: [
                Text("Need Help?"),
                SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: InkWell(
                    onTap: isWithinWorkingHours
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreChatScreen(
                                  storeID: widget.store.uuid,
                                  storeName: widget.store.name,
                                ),
                                settings: RouteSettings(name: '/store/chat'),
                              ),
                            );
                          }
                        : () {
                            Fluttertoast.showToast(msg: 'Store is closed');
                          },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.250,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat,
                              size: 15,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Chat",
                              style: TextStyle(
                                  fontSize: 14, color: CustomColors.black),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: isWithinWorkingHours
                              ? Colors.greenAccent[200]
                              : Colors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: isWithinWorkingHours
                        ? () async {
                            await UrlLauncherUtils.makePhoneCall(
                                widget.store.contacts.first.contactNumber);
                          }
                        : () {
                            Fluttertoast.showToast(msg: 'Store is closed');
                          },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.250,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.call,
                              size: 15,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Contact",
                              style: TextStyle(
                                  fontSize: 14, color: CustomColors.black),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: isWithinWorkingHours
                              ? Colors.red[100]
                              : Colors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () async {
                    await showDialog(
                        context: _scaffoldKey.currentContext,
                        builder: (context) {
                          return storeDialog();
                        });
                  },
                  child: Text(
                    "View more store details",
                    style: TextStyle(
                        decoration: TextDecoration.underline, fontSize: 12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget fixedAppBar(BuildContext context) {
    return Text(
      widget.store.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: isWithinWorkingHours
          ? FloatingActionButton.extended(
              backgroundColor: CustomColors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StoreOrderScreen(widget.store.uuid, widget.store.name),
                    settings: RouteSettings(name: '/store/cart'),
                  ),
                );
              },
              label: Text(
                "BUY NOW",
                style: TextStyle(color: CustomColors.black),
              ),
              icon: Icon(
                Icons.shopping_cart,
                color: CustomColors.black,
              ),
            )
          : Container(),
      body: CustomScrollView(
        reverse: false,
        slivers: [
          SliverAppBar(
            title: fixedAppBar(context),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_outlined,
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
            flexibleSpace:
                FlexibleSpaceBar(background: flexibleAppBar(context)),
          ),
          SliverPersistentHeader(
            delegate: SearchBar(widget.store),
            pinned: true,
          ),
          StoreCategoryWidget(widget.store),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          StorePopulartWidget(widget.store.uuid, widget.store.name),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          StoreProductWidget(widget.store.uuid, widget.store.name),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
            ),
          ),
        ],
      ),
    );
  }

  Widget storeDialog() {
    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        content: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.store.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CarouselIndicatorSlider(widget.store.storeImages),
                  SizedBox(
                    height: 5,
                  ),
                  widget.store.shortDetails.isNotEmpty
                      ? Flexible(child: Text(widget.store.shortDetails))
                      : Container(),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_today_outlined),
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
                      Icon(Icons.alarm),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[500],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateUtils.getFormattedTime(widget.store.activeFrom),
                          ),
                        ),
                      ),
                      Text("To"),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[500],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateUtils.getFormattedTime(widget.store.activeTill),
                          ),
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
                      Icon(Icons.delivery_dining),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[500],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(DateUtils.getFormattedTime(
                              widget.store.deliveryDetails.deliveryFrom)),
                        ),
                      ),
                      Text("To"),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[500],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(DateUtils.getFormattedTime(
                              widget.store.deliveryDetails.deliveryTill)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  border: Border.all(
                    color: Colors.grey[500],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: CustomColors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Iterable<Widget> get selectedDays sync* {
    for (MapEntry days in tempCollectionDays.entries) {
      yield Transform(
        transform: Matrix4.identity()..scale(0.8),
        child: ChoiceChip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          label: Text(
            days.value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: EdgeInsets.all(2),
          selected: widget.store.workingDays.contains(int.parse(days.key)),
          elevation: 2.0,
          selectedColor: CustomColors.green,
          backgroundColor: CustomColors.white,
          labelStyle: TextStyle(
              color: widget.store.workingDays.contains(int.parse(days.key))
                  ? Colors.black
                  : CustomColors.black),
        ),
      );
    }
  }
}

class SearchBar extends SliverPersistentHeaderDelegate {
  final Store store;

  SearchBar(this.store);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
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
              height: 50,
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: CustomColors.white),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        color: CustomColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CustomColors.black)),
                    child: Icon(
                      Icons.search,
                      size: 15,
                      color: CustomColors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      "Search for an item",
                      style: TextStyle(
                          fontSize: 16,
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

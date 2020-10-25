import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/StoreOrderScreen.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoryWidget.dart';
import 'package:chipchop_buyer/screens/store/StorePopularWidet.dart';
import 'package:chipchop_buyer/screens/store/StoreProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreProfileWidget.dart';
import 'package:chipchop_buyer/screens/utils/CarouselIndicatorSlider.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/CustomColors.dart';

class ViewStoreScreen extends StatefulWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  _ViewStoreScreenState createState() => _ViewStoreScreenState();
}

class _ViewStoreScreenState extends State<ViewStoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  int selectedItem = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        title: Text(
          widget.store.name,
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.alertRed,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StoreOrderScreen(widget.store.uuid, widget.store.name),
              settings: RouteSettings(name: '/cart'),
            ),
          ).then((value) {
            setState(() {
              selectedItem = 1;
            });
          });
        },
        label: Text("Order NOW"),
        icon: Icon(FontAwesomeIcons.solidSmile),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // StoreSearchBar(),
            Padding(
              padding: EdgeInsets.all(10),
              child: CarouselIndicatorSlider(widget.store.getStoreImages()),
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    color: CustomColors.white),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItem = 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.category,
                                    color: Color(0xFFAB436B),
                                  ),
                                ),
                              ),
                              Text(
                                "Categories",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    color: CustomColors.white),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItem = 2;
                                    });
                                  },
                                  child: Icon(FontAwesomeIcons.shoppingBasket,
                                      color: CustomColors.blue),
                                ),
                              ),
                              Text(
                                "Products",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    color: CustomColors.white),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItem = 3;
                                    });
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.angellist,
                                    color: CustomColors.green,
                                  ),
                                ),
                              ),
                              Text(
                                "Popular",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    color: CustomColors.white),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItem = 4;
                                    });
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.store,
                                    color: Color(0xFF4D9DA7),
                                  ),
                                ),
                              ),
                              Text(
                                "Info",
                                style: TextStyle(
                                    color: CustomColors.black,
                                    ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: Container(
                        color: CustomColors.lightGrey,
                      ),
                    ),
                    selectedItem == 1
                        ? Expanded(
                            child: Container(
                              child: StoreCategoryWidget(widget.store),
                            ),
                          )
                        : selectedItem == 2
                            ? Expanded(
                                child: Container(
                                  child: StoreProductWidget(
                                      widget.store.uuid, widget.store.name),
                                ),
                              )
                            : selectedItem == 3
                                ? Expanded(
                                    child: Container(
                                      child: StorePopulartWidget(
                                          widget.store.uuid, widget.store.name),
                                    ),
                                  )
                                : Expanded(
                                    child: Container(
                                      child: StoreProfileWidget(widget.store),
                                    ),
                                  )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

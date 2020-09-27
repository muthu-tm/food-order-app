import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoryWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreProfileWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreItemWidget extends StatefulWidget {
  final Store store;

  StoreItemWidget(this.store);

  @override
  _StoreItemWidgetState createState() => _StoreItemWidgetState();
}

class _StoreItemWidgetState extends State<StoreItemWidget> {
  int selectedItem = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: Icon(FontAwesomeIcons.shoppingBasket,
                            color: CustomColors.blue),
                      ),
                    ),
                    Text(
                      "Products",
                      style: TextStyle(
                          color: CustomColors.black, fontFamily: 'Georgia'),
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
                          color: CustomColors.black, fontFamily: 'Georgia'),
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
                        onPressed: () {},
                        child: Icon(
                          FontAwesomeIcons.clock,
                          color: Color(0xFFC1A17C),
                        ),
                      ),
                    ),
                    Text(
                      "Flash Sale",
                      style: TextStyle(
                          color: CustomColors.black, fontFamily: 'Georgia'),
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
                        child: Icon(
                          Icons.category,
                          color: Color(0xFFAB436B),
                        ),
                      ),
                    ),
                    Text(
                      "Categories",
                      style: TextStyle(
                          color: CustomColors.black, fontFamily: 'Georgia'),
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
                            selectedItem = 5;
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
                          color: CustomColors.black, fontFamily: 'Georgia'),
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
                    child: StoreProductWidget(widget.store.uuid),
                  ),
                )
              : selectedItem == 2
                  ? Expanded(
                      child: Container(
                        child: StoreCategoryWidget(widget.store),
                      ),
                    )
                  : selectedItem == 5
                      ? Expanded(
                          child: Container(
                            child: StoreProfileWidget(widget.store),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            child: StoreCategoryWidget(widget.store),
                          ),
                        )
        ],
      ),
    );
  }
}

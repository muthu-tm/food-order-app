import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/store/CategoriesProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/SubCategoriesProductScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoriesScreen extends StatefulWidget {
  StoreCategoriesScreen(
      this.subCategories, this.store, this.categoryID, this.categoryName);

  final List<ProductSubCategories> subCategories;
  final Store store;
  final String categoryID;
  final String categoryName;
  @override
  _StoreCategoriesScreenState createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _subCategoryID = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.categoryName,
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        backgroundColor: CustomColors.green,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: CustomColors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingCartScreen(),
                  settings: RouteSettings(name: '/cart'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    widget.subCategories.length > 0
                        ? ActionChip(
                            elevation: 6.0,
                            backgroundColor: _subCategoryID == ""
                                ? CustomColors.green
                                : Colors.white,
                            onPressed: () {
                              setState(() {
                                _subCategoryID = "";
                              });
                            },
                            label: Text(
                              "All",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _subCategoryID == ""
                                      ? Colors.black54
                                      : CustomColors.black),
                            ),
                          )
                        : Container(),
                    Container(
                      height: 60,
                      padding: const EdgeInsets.all(5.0),
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.subCategories.length,
                        padding: EdgeInsets.all(5),
                        itemBuilder: (BuildContext context, int index) {
                          ProductSubCategories _sc =
                              widget.subCategories[index];
                          return Padding(
                            padding: EdgeInsets.only(left: 5.0, right: 5),
                            child: ActionChip(
                              elevation: 6.0,
                              backgroundColor: _subCategoryID == _sc.uuid
                                  ? CustomColors.green
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  _subCategoryID = _sc.uuid;
                                });
                              },
                              label: Text(
                                _sc.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: _subCategoryID == _sc.uuid
                                        ? Colors.black54
                                        : CustomColors.black),
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
            _subCategoryID.isEmpty
                ? CategoriesProductsWidget(
                    widget.store.uuid, widget.store.name, widget.categoryID)
                : SubCategoriesProductsWidget(widget.store.uuid,
                    widget.store.name, widget.categoryID, _subCategoryID)
          ],
        ),
      ),
    );
  }
}

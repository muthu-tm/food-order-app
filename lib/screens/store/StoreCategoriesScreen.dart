import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/orders/ShoppingCartScreen.dart';
import 'package:chipchop_buyer/screens/store/CategoriesProductsWidget.dart';
import 'package:chipchop_buyer/screens/store/SubCategoriesProductScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoriesScreen extends StatefulWidget {
  StoreCategoriesScreen(this.store, this.categoryID, this.categoryName);

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
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder(
              future: ProductSubCategories().getSubCategoriesForIDs(
                  widget.categoryID, widget.store.availProductSubCategories),
              builder: (context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: Column(
                        children: AsyncWidgets.asyncWaiting(),
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Center(
                        child: Column(
                          children: AsyncWidgets.asyncError(),
                        ),
                      );
                    else
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          spacing: 5.0,
                          direction: Axis.horizontal,
                          children: List<Widget>.generate(
                            snapshot.data.length,
                            (index) {
                              ProductSubCategories _sc = snapshot.data[index];
                              return ActionChip(
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
                              );
                            },
                          ),
                        ),
                      );
                }
              },
            ),
          ),
          _subCategoryID.isEmpty
              ? CategoriesProductsWidget(
                  widget.store.uuid, widget.store.name, widget.categoryID)
              : SubCategoriesProductsWidget(widget.store.uuid,
                  widget.store.name, widget.categoryID, _subCategoryID)
        ],
      ),
    );
  }
}

import 'package:chipchop_buyer/db/models/order.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/orders/OrderWidget.dart';
import 'package:chipchop_buyer/screens/search/SearchOptionsRadio.dart';
import 'package:chipchop_buyer/screens/store/ProductWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  @override
  _SearchAppBarState createState() => new _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  int searchMode = 0;
  String searchKey = "";
  Future<List<Map<String, dynamic>>> snapshot;

  List<CustomRadioModel> inOutList = List<CustomRadioModel>();

  @override
  void initState() {
    super.initState();
    inOutList.add(
      CustomRadioModel(true, 'Store', ''),
    );
    inOutList.add(
      CustomRadioModel(false, 'Product', ''),
    );
    inOutList.add(
      CustomRadioModel(false, 'Order', ''),
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
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            color: CustomColors.white,
          ),
          decoration: InputDecoration(
            hintText: searchMode == 0
                ? "Type Store Name"
                : searchMode == 1 ? "Type Product Name" : "Type Order ID",
            hintStyle: TextStyle(color: CustomColors.white),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30.0,
              color: CustomColors.white,
            ),
            onPressed: () {
              if (_searchController.text.isEmpty ||
                  _searchController.text.trim().length < 3) {
                _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar("Enter minimum 3 digits", 2));
                return null;
              } else {
                searchKey = _searchController.text.trim();

                setState(
                  () {
                    searchMode == 0
                        ? snapshot = Products().getByNameRange(searchKey)
                        : searchMode == 1
                            ? snapshot = Products().getByNameRange(searchKey)
                            : snapshot = Order().getByOrderID(searchKey);
                  },
                );

                return null;
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.alertRed,
        tooltip: "Clear Results",
        onPressed: () {
          setState(() {
            searchKey = "";
            _searchController.text = "";
          });
        },
        elevation: 5.0,
        icon: Icon(
          Icons.remove_circle,
          size: 30,
          color: CustomColors.white,
        ),
        label: Text(
          "Clear",
        ),
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
                        if (inOutList[1].isSelected == true) {
                          return OrderWidget(
                              Order.fromJson(snapshot.data[index]));
                        } else {
                          return ProductWidget(
                              Products.fromJson(snapshot.data[index]));
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Text(
                          "No Search Triggerred yet!",
                          style: TextStyle(
                              color: CustomColors.blue, fontSize: 16.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Text(
                          "Try some keywords..",
                          style: TextStyle(
                              color: CustomColors.grey, fontSize: 16.0),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

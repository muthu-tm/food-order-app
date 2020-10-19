import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/search/ProductsListViewScreen.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/search/stores_in_map.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_localizations.dart';

class SearchHome extends StatefulWidget {
  @override
  _SearchHomeState createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: Container(
        color: CustomColors.lightGrey,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: SearchBarWidget(),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "OR",
                style: TextStyle(
                    fontFamily: 'Georgia',
                    color: CustomColors.grey,
                    fontSize: 18),
              ),
            ),
            InkWell(
              onTap: () async {
                if (cachedLocalUser.primaryLocation != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoresInMap(),
                      settings: RouteSettings(name: '/search/map'),
                    ),
                  );
                } else {
                  _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar(
                      AppLocalizations.of(context).translate('set_location'),
                      2,
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      FontAwesomeIcons.mapMarkedAlt,
                      size: 30,
                      color: CustomColors.positiveGreen,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                      child: Text(
                        "NearBy Stores in Map",
                        style: TextStyle(
                            fontFamily: 'Georgia',
                            color: CustomColors.black,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Daily Essentials",
                style: TextStyle(
                    fontFamily: "Georgia",
                    color: CustomColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            getDailyEssentials(context)
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getDailyEssentials(BuildContext context) {
    return FutureBuilder(
        future: ProductCategories().getSearchables(),
        builder: (context, AsyncSnapshot<List<ProductCategories>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Container();
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.spaceEvenly,
                  spacing: 6.0,
                  children:
                      List<Widget>.generate(snapshot.data.length, (int index) {
                    return ActionChip(
                        elevation: 6.0,
                        backgroundColor: CustomColors.green,
                        label: Text(
                          snapshot.data[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          List<Store> stores = await Store().getNearByStores(
                              cachedLocalUser
                                  .primaryLocation.geoPoint.geoPoint.latitude,
                              cachedLocalUser
                                  .primaryLocation.geoPoint.geoPoint.longitude,
                              10);

                          List<String> storeIDs = [];
                          for (var i = 0; i < stores.length; i++) {
                            storeIDs.add(stores[i].uuid);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductsListViewScreen(
                                  storeIDs, snapshot.data[index].uuid),
                              settings:
                                  RouteSettings(name: '/search/categories'),
                            ),
                          );
                        });
                  }),
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }
}

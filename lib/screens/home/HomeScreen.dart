import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/store/ProductWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: getPopularProducts(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getBanners() {
    return Container();
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
                        return Container(
                          height: 210,
                          child: ListView.builder(
                              shrinkWrap: true,
                              primary: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              padding: EdgeInsets.all(5),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.all(5.0),
                                  width: 150,
                                  child: ProductWidget(
                                    snapshot.data[index],
                                  ),
                                );
                              }),
                        );
                      }
                    } else {
                      return Container();
                    }
                  });
            } else {
              child = Container(
                padding: EdgeInsets.all(10),
                color: CustomColors.white,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Text(
                  "No Popular Products",
                  style: TextStyle(
                    
                    color: CustomColors.alertRed,
                    fontSize: 16.0,
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Center(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            );
          } else {
            child = Center(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            );
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

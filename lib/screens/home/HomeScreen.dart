import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
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
              child: TextFormField(
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14),
                //controller: _nController,
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: CustomColors.black,
                    size: 25.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 50,
                  ),
                  hintText: "Search for stores, items and categories",
                  hintMaxLines: 2,
                  fillColor: CustomColors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0,
                      color: CustomColors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
            ),
            //getBanners(),
            ListTile(
              title: Text(
                "Top Categories",
                style: TextStyle(
                    fontFamily: "Georgia",
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
                "Trending Products",
                style: TextStyle(
                    fontFamily: "Georgia",
                    color: CustomColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
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

  Widget getCategoryCards(BuildContext context) {
    return FutureBuilder(
      future: ProductTypes().getDashboardTypes(),
      builder: (context, AsyncSnapshot<List<ProductTypes>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              shrinkWrap: true,
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
                          settings: RouteSettings(name: '/topCategories'),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: CustomColors.green,
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
                                  color: CustomColors.black,
                                  fontFamily: 'Roboto-Light.ttf',
                                  fontSize: 14),
                            ),
                            Spacer(),
                            Icon(
                              FontAwesomeIcons.arrowAltCircleRight,
                              size: 20,
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
                  fontFamily: 'Georgia',
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

import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/search/ProductsListViewScreen.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class MoreCategoriesScreen extends StatefulWidget {
  @override
  _MoreCategoriesScreenState createState() => _MoreCategoriesScreenState();
}

class _MoreCategoriesScreenState extends State<MoreCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        centerTitle: true,
        titleSpacing: 0.0,
        title: Text(""),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: ProductTypes().getProductTypes(),
          builder: (context, AsyncSnapshot<List<ProductTypes>> snapshot) {
            Widget child;
            if (snapshot.hasData) {
              if (snapshot.data.isNotEmpty) {
                child = Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Explore All Available Categories",
                        style: TextStyle(
                            color: CustomColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          ProductTypes _types = snapshot.data[index];
                          return ExpansionTile(
                            title: Text(_types.name),
                            children: [
                              FutureBuilder(
                                future: ProductCategories()
                                    .getCategoriesForType(_types.uuid),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<ProductCategories>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data.isNotEmpty) {
                                      List<Widget> reasonList = [];
                                      snapshot.data.forEach((cat) {
                                        reasonList.add(ExpansionTile(
                                          title: Text(cat.name),
                                          children: [
                                            FutureBuilder(
                                              future: ProductSubCategories()
                                                  .getSubCategoriesForCategories(
                                                      cat.uuid),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          List<
                                                              ProductSubCategories>>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot
                                                      .data.isNotEmpty) {
                                                    List<Widget> reasonList =
                                                        [];
                                                    snapshot.data
                                                        .forEach((element) {
                                                      reasonList.add(ListTile(
                                                        dense: true,
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ListOfTopCategoryStores(
                                                                {
                                                                  'uuid':
                                                                      element
                                                                          .uuid,
                                                                  'name':
                                                                      element
                                                                          .name
                                                                },
                                                                'avail_product_sub_categories',
                                                                element.name,
                                                              ),
                                                              settings:
                                                                  RouteSettings(
                                                                      name:
                                                                          '/search/sub_categories.uuid'),
                                                            ),
                                                          );
                                                        },
                                                        title:
                                                            Text(element.name),
                                                      ));
                                                    });
                                                    return Column(
                                                        children: reasonList);
                                                  } else {
                                                    return Container();
                                                  }
                                                } else if (snapshot.hasError) {
                                                  return Container();
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                          ],
                                        ));
                                      });
                                      return Column(children: reasonList);
                                    } else {
                                      return Container();
                                    }
                                  } else if (snapshot.hasError) {
                                    return Container();
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          );
                        })
                  ],
                );
              } else {
                child = Container();
              }
            } else if (snapshot.hasError) {
              child = Container();
            } else {
              child = Container(
                alignment: Alignment.center,
                child: Column(children: AsyncWidgets.asyncWaiting()),
              );
            }
            return Column(
              children: [
                ListTile(
                  title: Text(
                    "Top Selling Categories",
                    style: TextStyle(
                        color: CustomColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
                getConfiguredCategories(context),
                child,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getConfiguredCategories(BuildContext context) {
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
                        elevation: 4.0,
                        backgroundColor: CustomColors.green,
                        label: Text(
                          snapshot.data[index].name,
                          style: TextStyle(color: CustomColors.black),
                        ),
                        onPressed: () async {
                          List<Store> stores = await Store().getStoresByTypes(
                              'avail_product_categories', {
                            'uuid': snapshot.data[index].uuid,
                            'name': snapshot.data[index].name
                          });

                          List<String> storeIDs = [];
                          for (var i = 0; i < stores.length; i++) {
                            storeIDs.add(stores[i].uuid);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductsListViewScreen(
                                  storeIDs, snapshot.data[index].uuid),
                              settings: RouteSettings(name: '/search/products'),
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

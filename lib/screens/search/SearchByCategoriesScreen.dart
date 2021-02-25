import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/product_types.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/search/CategoriesSearchScreen.dart';
import 'package:chipchop_buyer/screens/store/ListOfTopCategoryStores.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';

class SearchByCategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
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
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                              child: ProductTypeExpansionTile(_types),
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
            }),
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
                    ProductCategories cat = snapshot.data[index];
                    return ActionChip(
                        elevation: 4.0,
                        backgroundColor: CustomColors.green.withOpacity(0.4),
                        label: Text(
                          cat.name,
                          style: TextStyle(color: CustomColors.black),
                        ),
                        onPressed: () async {
                          CustomDialogs.actionWaiting(context);

                          List<ProductSubCategories> subCat =
                              await ProductSubCategories()
                                  .getSubCategoriesForCategories(cat.uuid);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorySearchScreen(
                                  {'uuid': cat.uuid, 'name': cat.name},
                                  'avail_product_categories',
                                  'product_category',
                                  cat.name,
                                  subCat),
                              settings: RouteSettings(
                                  name: '/search/categories/${cat.name}'),
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

class ProductTypeExpansionTile extends StatefulWidget {
  ProductTypeExpansionTile(this.type);
  final ProductTypes type;
  @override
  _ProductTypeExpansionTileState createState() =>
      _ProductTypeExpansionTileState();
}

class _ProductTypeExpansionTileState extends State<ProductTypeExpansionTile> {
  IconData trailingIcon = Icons.add_box;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTileTheme(
        dense: true,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListOfTopCategoryStores(
                        {'uuid': widget.type.uuid, 'name': widget.type.name},
                        'avail_products',
                        widget.type.name),
                    settings: RouteSettings(name: '/home/categories'),
                  ),
                );
              },
              child: Text(
                widget.type.name,
                style: TextStyle(fontSize: 15),
              ),
            ),
            trailing: Icon(
              trailingIcon,
              color: CustomColors.grey,
            ),
            onExpansionChanged: (val) {
              if (val) {
                setState(() {
                  trailingIcon = Icons.indeterminate_check_box;
                });
              } else {
                setState(() {
                  trailingIcon = Icons.add_box;
                });
              }
            },
            children: [
              FutureBuilder(
                future:
                    ProductCategories().getCategoriesForType(widget.type.uuid),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ProductCategories>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.isNotEmpty) {
                      return ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            ProductCategories cat = snapshot.data[index];
                            return InkWell(
                              onTap: () async {
                                CustomDialogs.actionWaiting(context);

                                List<ProductSubCategories> subCat =
                                    await ProductSubCategories()
                                        .getSubCategoriesForCategories(
                                            cat.uuid);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategorySearchScreen(
                                        {'uuid': cat.uuid, 'name': cat.name},
                                        'avail_product_categories',
                                        'product_category',
                                        cat.name,
                                        subCat),
                                    settings:
                                        RouteSettings(name: '/home/categories'),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cat.name,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          });
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
          ),
        ),
      ),
    );
  }
}

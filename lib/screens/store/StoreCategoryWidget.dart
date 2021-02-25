import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoriesScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StoreCategoryWidget extends StatefulWidget {
  StoreCategoryWidget(this.store);

  final Store store;

  @override
  _StoreCategoryWidgetState createState() => _StoreCategoryWidgetState();
}

class _StoreCategoryWidgetState extends State<StoreCategoryWidget> {
  var _future;

  bool viewLess = true;

  @override
  void initState() {
    super.initState();
    _future = ProductCategories().getCategoriesForIDs(
        widget.store.availProductCategories.map((e) => e.uuid).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<List<ProductCategories>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return SliverToBoxAdapter(
              child: Center(
                child: Container(),
              ),
            );
          default:
            if (snapshot.hasError)
              return SliverToBoxAdapter(
                child: Container(),
              );
            else
              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 5.0),
                        child: Text(
                          "You're looking for ?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            SizedBox(height: 10),
                            viewLess
                                ? StaggeredGridView.countBuilder(
                                    shrinkWrap: true,
                                    crossAxisCount: snapshot.data.length < 3
                                        ? snapshot.data.length
                                        : 3,
                                    itemCount: snapshot.data.length > 6
                                        ? 6
                                        : snapshot.data.length,
                                    padding: const EdgeInsets.all(2.0),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      ProductCategories item =
                                          snapshot.data[index];
                                      return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            height: 150,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: InkWell(
                                              onTap: () async {
                                                CustomDialogs.actionWaiting(
                                                    context);

                                                List<ProductSubCategories>
                                                    subCat =
                                                    await ProductSubCategories()
                                                        .getSubCategoriesForIDs(
                                                            item.uuid,
                                                            widget.store
                                                                .availProductSubCategories
                                                                .map((e) =>
                                                                    e.uuid)
                                                                .toList());

                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoreCategoriesScreen(
                                                            subCat,
                                                            widget.store,
                                                            item.uuid,
                                                            item.name),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    height: 120,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 5, 0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: CachedNetworkImage(
                                                        height: 110,
                                                        alignment:
                                                            Alignment.center,
                                                        imageUrl: item
                                                            .getCategoryImage(),
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                      CustomColors
                                                                          .blue),
                                                              strokeWidth: 2.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Text(
                                                      item.name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: CustomColors
                                                              .black,
                                                          fontSize: 10),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ));
                                    },
                                    staggeredTileBuilder: (int index) =>
                                        StaggeredTile.fit(1),
                                    mainAxisSpacing: 2.0,
                                    primary: false,
                                    crossAxisSpacing: 0.0,
                                  )
                                : StaggeredGridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    padding: const EdgeInsets.all(2.0),
                                    children: snapshot.data.map<Widget>((item) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: InkWell(
                                            onTap: () async {
                                              CustomDialogs.actionWaiting(
                                                  context);

                                              List<ProductSubCategories>
                                                  subCat =
                                                  await ProductSubCategories()
                                                      .getSubCategoriesForIDs(
                                                          item.uuid,
                                                          widget.store
                                                              .availProductSubCategories
                                                              .map(
                                                                  (e) => e.uuid)
                                                              .toList());

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StoreCategoriesScreen(
                                                          subCat,
                                                          widget.store,
                                                          item.uuid,
                                                          item.name),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  height: 120,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 0, 5, 0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: CachedNetworkImage(
                                                      height: 110,
                                                      alignment:
                                                          Alignment.center,
                                                      imageUrl: item
                                                          .getCategoryImage(),
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Center(
                                                        child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress,
                                                            valueColor:
                                                                AlwaysStoppedAnimation(
                                                                    CustomColors
                                                                        .blue),
                                                            strokeWidth: 2.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    item.name,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:
                                                            CustomColors.black,
                                                        fontSize: 10),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    staggeredTiles: snapshot.data
                                        .map<StaggeredTile>(
                                            (_) => StaggeredTile.fit(1))
                                        .toList(),
                                    mainAxisSpacing: 2.0,
                                    primary: false,
                                    crossAxisSpacing: 0.0,
                                  ),
                            snapshot.data.length > 6
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        viewLess = !viewLess;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.grid_view,
                                            size: 15,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            viewLess
                                                ? "View All Available Categories (${snapshot.data.length - 6})"
                                                : "View Less Categories",
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            viewLess
                                                ? Icons.keyboard_arrow_down
                                                : Icons.keyboard_arrow_up,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              );
        }
      },
    );
  }
}

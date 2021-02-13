import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/product_sub_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoriesScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class StoreCategoryWidget extends StatefulWidget {
  StoreCategoryWidget(this.store);

  final Store store;

  @override
  _StoreCategoryWidgetState createState() => _StoreCategoryWidgetState();
}

class _StoreCategoryWidgetState extends State<StoreCategoryWidget> {
  var _future;

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
                child: Column(
                  children: AsyncWidgets.asyncWaiting(),
                ),
              ),
            );
          default:
            if (snapshot.hasError)
              return SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: AsyncWidgets.asyncError(),
                  ),
                ),
              );
            else
              return SliverStickyHeader(
                header: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Available Categories",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  color: Colors.white,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      ProductCategories _c = snapshot.data[index];
                      return InkWell(
                        onTap: () async {
                          CustomDialogs.actionWaiting(context);

                          List<ProductSubCategories> subCat =
                              await ProductSubCategories()
                                  .getSubCategoriesForIDs(
                                      _c.uuid,
                                      widget.store.availProductSubCategories
                                          .map((e) => e.uuid)
                                          .toList());

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreCategoriesScreen(
                                  subCat, widget.store, _c.uuid, _c.name),
                            ),
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: _c.getCategoryImage(),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        valueColor: AlwaysStoppedAnimation(
                                            CustomColors.blue),
                                        strokeWidth: 2.0),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                _c.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: snapshot.data.length,
                  ),
                ),
              );
        }
      },
    );
  }
}

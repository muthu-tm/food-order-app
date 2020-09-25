import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoryWidget extends StatefulWidget {
  StoreCategoryWidget(this.store);

  final Store store;

  @override
  _StoreCategoryWidgetState createState() => _StoreCategoryWidgetState();
}

class _StoreCategoryWidgetState extends State<StoreCategoryWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProductCategories()
          .getCategoriesForIDs(widget.store.availProductCategories),
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              child: Text(
                "Loading...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          default:
            if (snapshot.hasError)
              return Container(
                child: Text(
                  "Error...",
                  style: TextStyle(color: CustomColors.black),
                ),
              );
            else
              return GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(1.0),
                childAspectRatio: 8.0 / 9.0,
                children: List<Widget>.generate(
                  snapshot.data.length,
                  (index) {
                    ProductCategories _c = snapshot.data[index];
                    return GridTile(
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => ProductsScreen()),
                          // );
                        },
                        child: Card(
                          color: CustomColors.white,
                          elevation: 0,
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                CachedNetworkImage(
                                  imageUrl: _c.getCategoryImage(),
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    fit: BoxFit.fill,
                                    image: imageProvider,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          valueColor: AlwaysStoppedAnimation(
                                              CustomColors.blue),
                                          strokeWidth: 2.0),
                                    ),
                                  ),
                                ),
                                Text(_c.name,
                                    style: TextStyle(
                                        color: CustomColors.black,
                                        fontFamily: 'Roboto-Light.ttf',
                                        fontSize: 12))
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
        }
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_categories.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/StoreCategoriesScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoryWidget extends StatelessWidget {
  StoreCategoryWidget(this.store);

  final Store store;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          ProductCategories().getCategoriesForIDs(store.availProductCategories),
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
              return GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(1.0),
                children: List<Widget>.generate(
                  snapshot.data.length,
                  (index) {
                    ProductCategories _c = snapshot.data[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoreCategoriesScreen(store, _c.uuid, _c.name),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: CustomColors.white,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CachedNetworkImage(
                                imageUrl: _c.getCategoryImage(),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill, image: imageProvider),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
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
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  _c.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontFamily: 'Roboto-Light.ttf',
                                      fontSize: 12),
                                ),
                              )
                            ],
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

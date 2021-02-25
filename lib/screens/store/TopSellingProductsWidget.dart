import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class TopSellingProductsWidget extends StatefulWidget {
  TopSellingProductsWidget(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _TopSellingProductsWidgetState createState() =>
      _TopSellingProductsWidgetState();
}

class _TopSellingProductsWidgetState extends State<TopSellingProductsWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products().getTopSellingProducts([widget.storeID], 10),
      builder: (BuildContext context, AsyncSnapshot<List<Products>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 5.0),
                      child: Text(
                        "Top selling products",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.grey[200],
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7.0),
                        height: 175,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          primary: true,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          itemBuilder: (BuildContext context, int index) {
                            Products product = snapshot.data[index];
                            return InkWell(
                              onTap: () {
                                UserActivityTracker _activity =
                                    UserActivityTracker();
                                _activity.keywords = "";
                                _activity.storeID = product.storeID;
                                _activity.productID = product.uuid;
                                _activity.productName = product.name;
                                _activity.refImage = product.getProductImage();
                                _activity.type = 2;
                                _activity.create();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailsScreen(product),
                                    settings:
                                        RouteSettings(name: '/store/products'),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  height: 160,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 120,
                                        alignment: Alignment.center,
                                        padding:
                                            const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: CachedNetworkImage(
                                            height: 110,
                                            alignment: Alignment.center,
                                            imageUrl: product.getProductImage(),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  value:
                                                      downloadProgress.progress,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          CustomColors.blue),
                                                  strokeWidth: 2.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CustomColors.black,
                                              fontSize: 10),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            children = SliverToBoxAdapter(
              child: Container(),
            );
          }
        } else if (snapshot.hasError) {
          children = SliverToBoxAdapter(
            child: Center(
              child: Container(),
            ),
          );
        } else {
          children = SliverToBoxAdapter(
            child: Container(),
          );
        }

        return children;
      },
    );
  }
}

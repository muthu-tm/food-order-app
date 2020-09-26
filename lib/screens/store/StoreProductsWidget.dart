import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'CartCounterWidget.dart';

class StoreProductWidget extends StatelessWidget {
  StoreProductWidget(this.storeID);

  final String storeID;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Products().streamAvailableProducts(storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              children: List.generate(snapshot.data.documents.length, (index) {
                Products product =
                    Products.fromJson(snapshot.data.documents[index].data);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product),
                        settings: RouteSettings(name: '/store/products'),
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
                    //height: 100,
                    //alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Hero(
                          tag: "${product.uuid}",
                          child: CachedNetworkImage(
                            imageUrl: product.getProductImage(),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 125,
                              height: 70,
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
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              size: 35,
                            ),
                            fadeOutDuration: Duration(seconds: 1),
                            fadeInDuration: Duration(seconds: 2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: CustomColors.blue,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            "${product.weight} ${product.getUnit()} - Rs. ${product.originalPrice.toString()}",
                            style: TextStyle(
                              color: CustomColors.blue,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        CartCounter()
                      ],
                    ),
                  ),
                );
              }),
            );
          } else {
            children = Container(
              height: 90,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    "No Product Available",
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                  Text(
                    "Sorry. Please Try Again Later!",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }

        return children;
      },
    );
  }
}

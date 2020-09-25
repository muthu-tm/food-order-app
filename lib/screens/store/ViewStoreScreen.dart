import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/PopularItemsWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreSearchBar.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';

class ViewStoreScreen extends StatelessWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: CustomColors.green, title: Text(store.storeName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoreSearchBar(),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 150.0,
                width: double.infinity,
                child: Carousel(
                  images: getImages(),
                  dotSize: 5.0,
                  dotSpacing: 20.0,
                  dotColor: CustomColors.blue,
                  indicatorBgPadding: 5.0,
                  dotBgColor: CustomColors.black.withOpacity(0.2),
                  borderRadius: true,
                  radius: Radius.circular(20),
                  noRadiusForIndicator: true,
                ),
              ),
            ),
            PopularMenu(),
          ],
        ),
      ),
    );
  }

  List<Widget> getImages() {
    List<Widget> images = [];

    for (var item in store.getStoreImages()) {
      images.add(CachedNetworkImage(
        imageUrl: item,
        imageBuilder: (context, imageProvider) => Image(
          height: 150,
          width: double.infinity,
          fit: BoxFit.contain,
          image: imageProvider,
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          size: 35,
        ),
        fadeOutDuration: Duration(seconds: 1),
        fadeInDuration: Duration(seconds: 2),
      ));
    }

    return images;
  }
}

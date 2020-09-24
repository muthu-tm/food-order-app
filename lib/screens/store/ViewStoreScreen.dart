import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/store.dart';
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
          backgroundColor: CustomColors.blue, title: Text(store.storeName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 150.0,
                width: double.infinity,
                child: Carousel(
                  images: [
                    CachedNetworkImage(
                      imageUrl: store.getProfilePicPath(),
                      imageBuilder: (context, imageProvider) => Image(
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        image: imageProvider,
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
                  ],
                  dotSize: 4.0,
                  dotSpacing: 15.0,
                  dotColor: CustomColors.green,
                  indicatorBgPadding: 5.0,
                  dotBgColor: CustomColors.black.withOpacity(0.1),
                  borderRadius: true,
                  radius: Radius.circular(20),
                  moveIndicatorFromBottom: 180.0,
                  noRadiusForIndicator: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

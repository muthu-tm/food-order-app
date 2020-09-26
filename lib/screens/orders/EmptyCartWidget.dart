import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:flutter/material.dart';

class EmptyCartWidget extends StatefulWidget {
  @override
  _EmptyCartWidgetState createState() =>
      _EmptyCartWidgetState();
}

class _EmptyCartWidgetState extends State<EmptyCartWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: CustomColors.white),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 70,
              child: Container(
                color: CustomColors.white,
              ),
            ),
            Container(
              width: double.infinity,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: empty_cart_placeholder.replaceFirst(
                    firebase_storage_path, image_kit_path),
                imageBuilder: (context, imageProvider) => Image(
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  image: imageProvider,
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        valueColor: AlwaysStoppedAnimation(CustomColors.blue),
                        strokeWidth: 2.0),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  size: 35,
                ),
                fadeOutDuration: Duration(seconds: 1),
                fadeInDuration: Duration(seconds: 2),
              ),
            ),
            SizedBox(
              height: 40,
              child: Container(
                color: CustomColors.white,
              ),
            ),
            Container(
              width: double.infinity,
              child: Text(
                "Your cart is Empty!!",
                style: TextStyle(
                  color: CustomColors.black,
                  fontFamily: 'Georgia',
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

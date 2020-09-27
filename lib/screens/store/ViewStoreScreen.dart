import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/store/StoreItemWidget.dart';
import 'package:chipchop_buyer/screens/store/StoreSearchBar.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewStoreScreen extends StatelessWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        title: Text(store.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.only(left: 10, right: 10),
            //   child: Container(
            //     height: 150.0,
            //     width: double.infinity,
            //     child: Carousel(
            //       images: getImages(),
            //       dotSize: 5.0,
            //       dotSpacing: 20.0,
            //       dotColor: CustomColors.blue,
            //       indicatorBgPadding: 5.0,
            //       dotBgColor: CustomColors.black.withOpacity(0.2),
            //       borderRadius: true,
            //       radius: Radius.circular(20),
            //       noRadiusForIndicator: true,
            //     ),
            //   ),
            // ),
            StoreSearchBar(),
            Expanded(
              child: StoreItemWidget(store),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Icon(FontAwesomeIcons.smile, color: CustomColors.positiveGreen,),
                  ),
                  Text(
                    "Order NOW!",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: RaisedButton(
                        color: CustomColors.lightGreen,
                        onPressed: () {},
                        child: Text("From Cart")),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: RaisedButton(
                        color: CustomColors.lightBlue,
                        onPressed: () {},
                        child: Text("Type Order")),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: RaisedButton(
                        color: CustomColors.lightGreen,
                        onPressed: () {},
                        child: Text("Capture Order")),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  List<Widget> getImages() {
    List<Widget> images = [];

    for (var item in store.getStoreImages()) {
      images.add(
        CachedNetworkImage(
          imageUrl: item,
          imageBuilder: (context, imageProvider) => Image(
            height: 150,
            width: double.infinity,
            fit: BoxFit.contain,
            image: imageProvider,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
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
      );
    }

    return images;
  }
}

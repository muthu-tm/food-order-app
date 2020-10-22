import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class CarouselIndicatorSlider extends StatefulWidget {
  CarouselIndicatorSlider(this.imgList);

  final List<String> imgList;
  @override
  State<StatefulWidget> createState() {
    return _CarouselIndicatorSliderState(imgList: imgList);
  }
}

class _CarouselIndicatorSliderState extends State<CarouselIndicatorSlider> {
  _CarouselIndicatorSliderState({@required this.imgList});

  List<String> imgList;

  int _current = 0;

  List<Widget> getSliders() {
    return imgList
        .map((item) => Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: CachedNetworkImage(
                    imageUrl: item,
                    imageBuilder: (context, imageProvider) => Image(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      image: imageProvider,
                    ),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            valueColor:
                                AlwaysStoppedAnimation(CustomColors.green),
                            strokeWidth: 2.0),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      size: 35,
                    ),
                    fadeOutDuration: Duration(seconds: 1),
                    fadeInDuration: Duration(seconds: 2),
                  )),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: getSliders(),
        options: CarouselOptions(
            autoPlay: imgList.length > 1 ? true : false,
            enlargeCenterPage: imgList.length > 1 ? true : false,
            enableInfiniteScroll: imgList.length <= 1 ? false : true,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imgList.map((url) {
          int index = imgList.indexOf(url);
          return Container(
            width: _current == index ? 10.0 : 6.0,
            height: _current == index ? 10.0 : 6.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? CustomColors.green
                  : CustomColors.alertRed,
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

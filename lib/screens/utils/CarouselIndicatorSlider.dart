import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class CarouselIndicatorSlider extends StatefulWidget {
  CarouselIndicatorSlider(this.imgList,
      {this.height = 180, this.bg = Colors.transparent, this.onClick});
  final double height;
  final List<String> imgList;
  final Color bg;
  final List<Function> onClick;
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
    List<Widget> childs = [];

    for (int i = 0; i < imgList.length; i++) {
      String item = imgList[i];
      childs.add(
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
            child: InkWell(
              onTap: widget.onClick != null ? widget.onClick[i] : null,
              child: CachedNetworkImage(
                imageUrl: item,
                imageBuilder: (context, imageProvider) => Image(
                  width: double.infinity,
                  fit: BoxFit.fill,
                  image: imageProvider,
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        valueColor: AlwaysStoppedAnimation(CustomColors.green),
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
          ),
        ),
      );
    }
    return childs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: getSliders(),
        options: CarouselOptions(
            viewportFraction: 1.0,
            height: widget.height,
            autoPlay: true,
            autoPlayAnimationDuration: Duration(seconds: 1),
            enlargeCenterPage: false,
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
            width: 25.0,
            height: 5.0,
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.black),
              color:
                  _current == index ? Colors.black54 : CustomColors.lightGrey,
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

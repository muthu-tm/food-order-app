import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchProductsWidget extends StatefulWidget {
  SearchProductsWidget(this.product);

  final Products product;

  @override
  _SearchProductsWidgetState createState() => _SearchProductsWidgetState();
}

class _SearchProductsWidgetState extends State<SearchProductsWidget> {
  String _variant = "0";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          UserActivityTracker _activity = UserActivityTracker();
          _activity.keywords = "";
          _activity.storeID = widget.product.storeID;
          _activity.productID = widget.product.uuid;
          _activity.productName = widget.product.name;
          _activity.refImage = widget.product.getProductImage();
          _activity.type = 2;
          _activity.create();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(widget.product),
              settings: RouteSettings(name: '/store/products/view'),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            color: CustomColors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: CachedNetworkImage(
                  imageUrl: widget.product.getProductImage(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 80,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          fit: BoxFit.fill, image: imageProvider),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
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
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        (widget.product.variants.length == 1)
                            ? Container(
                                height: 25,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                // dropdown below..
                                child: Text(
                                  "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
                                  style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 13.0,
                                  ),
                                ),
                              )
                            : Container(
                                height: 25,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                // dropdown below..
                                child: DropdownButton<String>(
                                  value: _variant,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: CustomColors.green,
                                  ),
                                  iconSize: 30,
                                  underline: SizedBox(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _variant = newValue;
                                    });
                                  },
                                  items: List.generate(
                                      widget.product.variants.length,
                                      (int index) {
                                    return DropdownMenuItem(
                                      value: widget.product.variants[index].id,
                                      child: Container(
                                        child: Text(
                                          "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                                          style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                        SizedBox(width: 10),
                        Text(
                          " ₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toString()}",
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 12.0,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

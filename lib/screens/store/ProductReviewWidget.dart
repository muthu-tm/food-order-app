import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/product_reviews.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class ProductReviewWidget extends StatelessWidget {
  ProductReviewWidget(this.productID, this.productName);

  final String productID;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: getReviewDetails(productID),
      ),
    );
  }

  Widget getReviewDetails(String productID) {
    return FutureBuilder(
        future: ProductReviews().getAllReviews(productID),
        builder: (context, AsyncSnapshot<List<ProductReviews>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              child = ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductReviewDetailed(
                                  snapshot.data[index], productName),
                              settings:
                                  RouteSettings(name: 'store/products/review'),
                            ),
                          );
                        },
                        leading: Column(
                          children: [
                            Text(
                              snapshot.data[index].rating.toString(),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        title: Text(
                          snapshot.data[index].title,
                          maxLines: 2,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data[index].review,
                              maxLines: 3,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  snapshot.data[index].userName,
                                  style: TextStyle(
                                      fontSize: 12, color: CustomColors.grey),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 15,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  DateUtils.formatDateTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        snapshot.data[index].createdTime),
                                  ),
                                  style: TextStyle(
                                      fontSize: 12, color: CustomColors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              child = Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Text(
                  "No Reviews !!",
                  style: TextStyle(fontSize: 16.0, color: CustomColors.blue),
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Center(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            );
          } else {
            child = Center(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            );
          }
          return child;
        });
  }
}

class ProductReviewDetailed extends StatelessWidget {
  final ProductReviews review;
  final String productName;

  ProductReviewDetailed(this.review, this.productName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review - $productName",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      review.rating.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(review.userName),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  DateUtils.formatDateTime(
                    DateTime.fromMillisecondsSinceEpoch(review.createdTime),
                  ),
                  style: TextStyle(fontSize: 12, color: CustomColors.grey),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                review.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                review.review,
              ),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                primary: false,
                mainAxisSpacing: 10,
                children: List.generate(
                  review.images.length,
                  (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageView(
                                url: review.images[index],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: review.images[index],
                              imageBuilder: (context, imageProvider) => Image(
                                fit: BoxFit.fill,
                                image: imageProvider,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

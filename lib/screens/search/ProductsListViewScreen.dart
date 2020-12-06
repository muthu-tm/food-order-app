import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_buyer/screens/store/VariantsWidget.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ProductsListViewScreen extends StatefulWidget {
  ProductsListViewScreen(this.storeIDs, this.categoryID);

  final List<String> storeIDs;
  final String categoryID;
  @override
  _ProductsListViewScreenState createState() => _ProductsListViewScreenState();
}

class _ProductsListViewScreenState extends State<ProductsListViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.lightGrey,
        appBar: AppBar(
          title: Text(
            "Products",
            textAlign: TextAlign.start,
            style: TextStyle(color: CustomColors.black, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: CustomColors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: CustomColors.green,
        ),
        body: Container(
          child: SingleChildScrollView(
            child: getProducts(context),
          ),
        ));
  }

  Widget getProducts(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products()
          .getProductsForCategories(widget.storeIDs, widget.categoryID),
      builder: (BuildContext context, AsyncSnapshot<List<Products>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = ListView.builder(
                scrollDirection: Axis.vertical,
                primary: true,
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Products product = snapshot.data[index];
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: CustomColors.white,
                      ),
                      child: InkWell(
                        onTap: () {
                          UserActivityTracker _activity = UserActivityTracker();
                          _activity.keywords = "";
                          _activity.storeID = product.storeID;
                          _activity.productID = product.uuid;
                          _activity.productName = product.name;
                          _activity.type = 2;
                          _activity.create();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product),
                              settings: RouteSettings(
                                  name: '/search/categgories/products/view'),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: product.getProductImage(),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 60,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
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
                          title: Text(
                            product.name,
                            style: TextStyle(
                              color: CustomColors.blue,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: ProductVariantsWidget(product, 0),
                        ),
                      ),
                    ),
                  );
                });
          } else {
            children = Center(
              child: Container(
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

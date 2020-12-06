import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_buyer/db/models/product_reviews.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/app/TakePicturePage.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/storage/image_uploader.dart';
import 'package:chipchop_buyer/services/storage/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProductReviewScreen extends StatefulWidget {
  ProductReviewScreen(this.product);

  final Products product;
  @override
  _ProductReviewScreenState createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _feedbackController;
  TextEditingController _headlineController;
  List<String> imagePaths = [];
  double ratings;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _headlineController = TextEditingController();
    ratings = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Review - ${widget.product.name}",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Help us improve!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              SizedBox(
                height: 10,
              ),
              Text("Rate the Product"),
              Align(
                alignment: Alignment.centerRight,
                child: RatingBar.builder(
                  initialRating: ratings,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    ratings = rating;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Add Image"),
              ListTile(
                leading: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding:
                      EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 5),
                  color: CustomColors.grey,
                  onPressed: () async {
                    try {
                      String tempPath = (await getTemporaryDirectory()).path;
                      String filePath = '$tempPath/chipchop_image.png';
                      if (File(filePath).existsSync())
                        await File(filePath).delete();
                      await _showCamera(filePath);
                    } catch (err) {
                      Fluttertoast.showToast(msg: 'This file is not an image');
                    }
                  },
                  label: Text(
                    "Capture",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: CustomColors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(FontAwesomeIcons.cameraRetro),
                ),
                trailing: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: CustomColors.blueGreen,
                  onPressed: () async {
                    String imageUrl = '';
                    try {
                      ImagePicker imagePicker = ImagePicker();
                      PickedFile pickedFile;

                      pickedFile = await imagePicker.getImage(
                          source: ImageSource.gallery);
                      if (pickedFile == null) return;

                      String fileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      String fbFilePath =
                          'product_reviews/${cachedLocalUser.getID()}/$fileName.png';
                      CustomDialogs.actionWaiting(context);
                      // Upload to storage
                      imageUrl = await Uploader()
                          .uploadImageFile(true, pickedFile.path, fbFilePath);
                      Navigator.of(context).pop();
                    } catch (err) {
                      Fluttertoast.showToast(msg: 'This file is not an image');
                    }
                    if (imageUrl != "")
                      setState(() {
                        imagePaths.add(imageUrl);
                      });
                  },
                  label: Text(
                    "Pick Image",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: CustomColors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(FontAwesomeIcons.images),
                ),
              ),
              imagePaths.length > 0
                  ? GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      shrinkWrap: true,
                      primary: false,
                      mainAxisSpacing: 10,
                      children: List.generate(
                        imagePaths.length,
                        (index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageView(
                                          url: imagePaths[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: imagePaths[index],
                                        imageBuilder:
                                            (context, imageProvider) => Image(
                                          fit: BoxFit.fill,
                                          image: imageProvider,
                                        ),
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Center(
                                          child: SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        CustomColors.blue),
                                                strokeWidth: 2.0),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          size: 35,
                                        ),
                                        fadeOutDuration: Duration(seconds: 1),
                                        fadeInDuration: Duration(seconds: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CustomColors.alertRed,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: InkWell(
                                    child: Icon(
                                      Icons.close,
                                      size: 25,
                                      color: CustomColors.white,
                                    ),
                                    onTap: () async {
                                      CustomDialogs.actionWaiting(context);
                                      bool res = await StorageUtils()
                                          .removeFile(imagePaths[index]);
                                      Navigator.of(context).pop();
                                      if (res)
                                        setState(() {
                                          imagePaths.remove(imagePaths[index]);
                                        });
                                      else
                                        Fluttertoast.showToast(
                                            msg: 'Unable to remove image');
                                    },
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              Text("Review Headline"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textAlign: TextAlign.start,
                  autofocus: false,
                  controller: _headlineController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                      ),
                    ),
                    fillColor: CustomColors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Provide your feedback"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  autofocus: false,
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                      ),
                    ),
                    fillColor: CustomColors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                    color: CustomColors.alertRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      ProductReviews review = ProductReviews();
                      review.images = imagePaths;
                      review.title = _headlineController.text;
                      review.review = _feedbackController.text;
                      review.rating = ratings;

                      await review.create(widget.product.uuid);
                      Navigator.pop(context);
                    },
                    child: Text("Submit"),
                    color: CustomColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCamera(String filePath) async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription camera = cameras.first;

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicturePage(
          camera: camera,
          path: filePath,
        ),
      ),
    );
    if (result != null) {
      CustomDialogs.actionWaiting(context);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath =
          'product_reviews/${cachedLocalUser.getID()}/$fileName.png';
      String imageUrl = '';
      try {
        imageUrl =
            await Uploader().uploadImageFile(true, result.toString(), filePath);
        Navigator.of(context).pop();
        setState(() {
          imagePaths.add(imageUrl);
        });
      } catch (err) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'Sorry, Unable to perform the action!');
      }
    }
  }
}

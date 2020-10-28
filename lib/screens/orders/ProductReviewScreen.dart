import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/ImageView.dart';
import 'package:chipchop_buyer/services/storage/image_uploader.dart';
import 'package:chipchop_buyer/services/storage/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'ShoppingCartScreen.dart';

class ProductReviewScreen extends StatefulWidget {
  @override
  _ProductReviewScreenState createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _feedbackController;
  TextEditingController _headlineController;
  List<String> imagePaths = [];
  String _userNumber = "0";
  double ratings;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _headlineController = TextEditingController();
    ratings = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Add a review",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        backgroundColor: CustomColors.green,
        elevation: 0,
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
              Text("Please rate your experience"),
              RatingBar(
                initialRating: ratings,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
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
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: CustomColors.alertRed,
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
                      String fbFilePath = 'reviews/$_userNumber/$fileName.png';
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
                    "Add Image",
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
              Text("Add a headline"),
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
                  maxLines: 3,
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
                    onPressed: () {},
                    child: Text("Submit"),
                    color: CustomColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                    color: CustomColors.alertRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
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
}

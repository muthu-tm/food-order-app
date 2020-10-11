import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:flutter/material.dart';

import 'ViewStoreScreen.dart';

class ListOfTopCategoryStores extends StatelessWidget {
  final String typeID;
  final String categoryName;
  ListOfTopCategoryStores(this.typeID, this.categoryName);

  @override
  Widget build(BuildContext context) {
    Widget getListOfStores() {
      return FutureBuilder(
        future: Store().getStoresByTypes(typeID),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              child = Container(
                child: Center(
                  child: Text(
                    "No stores",
                    style: TextStyle(color: CustomColors.black),
                  ),
                ),
              );
            } else {
              child = ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Store store = snapshot.data[index];

                  return Container(
                    height: 145,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewStoreScreen(store),
                                  settings: RouteSettings(name: '/store'),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Container(
                                    height: 75,
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: store.getStoreImages().first,
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
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        store.name,
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          color: CustomColors.blue,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        child: Text(
                                          "Timings - ${store.activeFrom} : ${store.activeTill}",
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            color: CustomColors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            color: Colors.grey.shade300,
                            height: 1,
                            width: double.infinity,
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Spacer(
                                  flex: 2,
                                ),
                                FlatButton.icon(
                                  onPressed: () async {
                                    await UrlLauncherUtils.makePhoneCall(
                                        store.contacts.first.contactNumber);
                                  },
                                  label: Text(
                                    "Contact",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: CustomColors.blueGreen),
                                  ),
                                  icon: Icon(Icons.call_end),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                Spacer(
                                  flex: 3,
                                ),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                Spacer(
                                  flex: 3,
                                ),
                                FlatButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreChatScreen(
                                          storeID: store.uuid,
                                          storeName: store.name,
                                        ),
                                        settings:
                                            RouteSettings(name: '/store/chat'),
                                      ),
                                    );
                                  },
                                  label: Text(
                                    "Chat",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: CustomColors.blueGreen),
                                  ),
                                  icon: Icon(Icons.chat),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                Spacer(
                                  flex: 2,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else if (snapshot.hasError) {
            child = Container(
              child: Text(
                "Error...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          } else {
            child = Container(
              child: Text(
                "Loading...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          }
          return child;
        },
      );
    }

    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      backgroundColor: CustomColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "Top $categoryName stores",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            getListOfStores()
          ],
        ),
      ),
    );
  }
}

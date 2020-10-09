import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/chat_temp.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ChatsHome extends StatefulWidget {

  @override
  _ChatsHomeState createState() => _ChatsHomeState();
}

class _ChatsHomeState extends State<ChatsHome>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Chats",
            textAlign: TextAlign.start,
            style: TextStyle(color: CustomColors.black, fontSize: 16),
          ),
          backgroundColor: CustomColors.green,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: getBody(context),
        ));
  }

  Widget getBody(BuildContext context) {
    return FutureBuilder(
      future: ChatTemplate().getStoreChatsList(),
      builder: (context, AsyncSnapshot<List<Store>> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null || snapshot.data.length == 0) {
            child = Center(
              child: Container(
                child: Text(
                  "No Chats",
                  style: TextStyle(color: CustomColors.black),
                ),
              ),
            );
          } else {
            child = Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                primary: true,
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Store _s = snapshot.data[index];
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoreChatScreen(storeID: _s.uuid, storeName: _s.name,),
                            settings: RouteSettings(name: '/chats/store'),
                          ),
                        );
                      },
                      leading: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: _s.getStoreImages().first,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 45.0,
                              backgroundImage: imageProvider,
                              backgroundColor: Colors.transparent,
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
                        ),
                      ),
                      title: Text(
                        _s.name,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Container(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          child = Container(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }

        return child;
      },
    );
  }
}

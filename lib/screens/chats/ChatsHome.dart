import 'package:chipchop_buyer/db/models/chat_temp.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return StreamBuilder(
      stream: ChatTemplate().streamStoreChatsList(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data.documents.length == 0) {
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
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoreChatScreen(
                              storeID: snapshot
                                  .data.documents[index].data['store_uuid'],
                              storeName: snapshot
                                  .data.documents[index].data['store_name'],
                            ),
                            settings: RouteSettings(name: '/chats/store'),
                          ),
                        ).then((value) async {
                          await ChatTemplate().updateToRead(snapshot
                              .data.documents[index].data['store_uuid']);
                        });
                      },
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: CustomColors.grey,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Icon(
                          Icons.store,
                          color: CustomColors.green,
                        ),
                      ),
                      trailing: (snapshot.data.documents[index].data
                                  .containsKey('has_customer_unread') &&
                              snapshot.data.documents[index]
                                  .data['has_customer_unread'])
                          ? Icon(
                              Icons.question_answer,
                              color: CustomColors.alertRed,
                            )
                          : Text(""),
                      title: Text(
                        snapshot.data.documents[index].data['store_name'],
                      ),
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

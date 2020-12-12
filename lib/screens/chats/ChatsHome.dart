import 'package:chipchop_buyer/db/models/chat_temp.dart';
import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
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
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: getBody(context),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getBody(BuildContext context) {
    return FutureBuilder(
      future: Customers().getUsersStores(),
      builder: (context, AsyncSnapshot<List<Customers>> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data.length == 0) {
            child = Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Icon(
                      Icons.question_answer,
                      size: 30,
                    ),
                    Text(
                      "No Chats !!",
                      style: TextStyle(color: CustomColors.black),
                    ),
                  ],
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
                  Customers _cust = snapshot.data[index];

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreChatScreen(
                                storeID: _cust.storeID,
                                storeName: _cust.storeName,
                              ),
                              settings: RouteSettings(name: '/chats/store'),
                            ),
                          ).then((value) async {
                            await ChatTemplate().updateToRead(_cust.storeID);
                          });
                        },
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: CustomColors.black,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Icon(
                            Icons.store,
                            color: CustomColors.white,
                          ),
                        ),
                        trailing: (_cust.hasCustUnread)
                            ? Icon(
                                Icons.question_answer,
                                color: CustomColors.alertRed,
                              )
                            : Text(""),
                        title: Text(
                          _cust.storeName,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
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

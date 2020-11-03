import 'package:chipchop_buyer/db/models/chat_temp.dart';
import 'package:chipchop_buyer/screens/chats/ChatsHome.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool newStoreNotification = false;

class ChatBottomWidget extends StatefulWidget {
  ChatBottomWidget(this.size);

  final Size size;

  @override
  _ChatBottomWidgetState createState() => _ChatBottomWidgetState();
}

class _ChatBottomWidgetState extends State<ChatBottomWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _newStoreNotification = false;
  @override
  void initState() {
    super.initState();
    _newStoreNotification = newStoreNotification;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          ChatTemplate().updateToUnRead(message['data']['store_uuid']);
          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(message['data']['store_uuid']);

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(message['data']['store_uuid']);

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onResume: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    _newStoreNotification
        ? child = SizedBox.fromSize(
            size: widget.size,
            child: InkWell(
              onTap: () {
                setState(() {
                    _newStoreNotification = false;
                    newStoreNotification = false;
                  });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatsHome(),
                    settings: RouteSettings(name: '/chats'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(alignment: Alignment.center, children: <Widget>[
                    Icon(
                      Icons.question_answer,
                      size: 25.0,
                      color: CustomColors.black,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: CustomColors.alertRed,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '',
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 3,
                  ),
                  Text("Chats",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orienta()),
                ],
              ),
            ),
          )
        : child = SizedBox.fromSize(
            size: widget.size,
            child: InkWell(
              onTap: () {
                setState(() {
                    _newStoreNotification = false;
                    newStoreNotification = false;
                  });
                  
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatsHome(),
                    settings: RouteSettings(name: '/chats'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.question_answer,
                    size: 25.0,
                    color: CustomColors.black,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text("Chats", style: GoogleFonts.orienta()),
                ],
              ),
            ),
          );

    return child;
  }
}

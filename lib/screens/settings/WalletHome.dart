import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/screens/settings/StoreWalletScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalletHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${cachedLocalUser.firstName} ${cachedLocalUser.lastName}',
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
      body: StreamBuilder(
          stream: Customers().streamUsersStores(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.documents.length == 0) {
                child = Center(
                  child: Container(
                    child: Text(
                      "No Stores Linked YET!",
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
                      Customers cust = Customers.fromJson(
                          snapshot.data.documents[index].data);
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreWalletScreen(
                                    cust.storeID, cust.storeName),
                                settings: RouteSettings(
                                    name: '/settings/wallet/store'),
                              ),
                            );
                          },
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: CustomColors.grey,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Icon(
                              Icons.person,
                              color: CustomColors.green,
                            ),
                          ),
                          title: Text(
                            cust.storeName,
                          ),
                          subtitle: Text(
                            '${cust.availableBalance}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Georgia',
                              color: cust.availableBalance.isNegative
                                  ? CustomColors.alertRed
                                  : CustomColors.green,
                            ),
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
          }),
    );
  }
}

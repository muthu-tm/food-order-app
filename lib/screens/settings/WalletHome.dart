import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/screens/settings/StoreWalletScreen.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
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
      body: FutureBuilder(
          future: Customers().getUsersStores(),
          builder: (context, AsyncSnapshot<List<Customers>> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
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
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Customers cust = snapshot.data[index];

                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: Card(
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
                                color: cust.availableBalance.isNegative
                                    ? CustomColors.alertRed
                                    : CustomColors.green,
                              ),
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
          }),
    );
  }
}

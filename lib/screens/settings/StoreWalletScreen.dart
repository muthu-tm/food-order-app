import 'package:chipchop_buyer/db/models/customers.dart';
import 'package:chipchop_buyer/db/models/user_store_wallet_history.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StoreWalletScreen extends StatefulWidget {
  StoreWalletScreen(this.storeID, this.storeName);

  final String storeID;
  final String storeName;

  @override
  _StoreWalletScreenState createState() => _StoreWalletScreenState();
}

class _StoreWalletScreenState extends State<StoreWalletScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        title: Text(
          '${widget.storeName}',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
              child: getWalletWidget(),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: getTransactionHistoryWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getWalletWidget() {
    return StreamBuilder(
      stream: Customers().streamUsersData(widget.storeID),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget widget;

        if (snapshot.hasData) {
          if (snapshot.data.exists && snapshot.data.data.isNotEmpty) {
            Customers _cust = Customers.fromJson(snapshot.data.data);
            double amount = _cust.availableBalance;

            widget = Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 5.0,
                shadowColor: CustomColors.green.withOpacity(0.7),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Available Balance",
                        style: TextStyle(
                          color: CustomColors.green,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rs.${amount ?? 0.00}",
                        style: TextStyle(
                          color: CustomColors.green,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            widget = Card(
              elevation: 5.0,
              shadowColor: CustomColors.alertRed.withOpacity(0.7),
              child: Container(
                padding: EdgeInsets.all(10),
                height: 50,
                child: Text(
                  "Rs.0.00",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.green,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          widget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: AsyncWidgets.asyncError());
        } else {
          widget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: AsyncWidgets.asyncWaiting());
        }

        return Card(
          color: CustomColors.lightGrey,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  size: 35.0,
                  color: CustomColors.alertRed,
                ),
                title: Text(
                  "Wallet Amount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.green,
                    fontSize: 17.0,
                  ),
                ),
              ),
              Divider(
                color: CustomColors.green,
              ),
              widget,
            ],
          ),
        );
      },
    );
  }

  Widget getTransactionHistoryWidget() {
    return StreamBuilder(
      stream: UserStoreWalletHstory().streamUsersStoreWallet(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget widget;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            widget = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                UserStoreWalletHstory history = UserStoreWalletHstory.fromJson(
                    snapshot.data.documents[index].data);

                Color tileColor = CustomColors.green;
                Color textColor = CustomColors.white;

                if (index % 2 == 0) {
                  tileColor = CustomColors.white;
                  textColor = CustomColors.alertRed;
                }

                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Material(
                    color: tileColor,
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 75,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: tileColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.local_offer,
                              size: 35.0,
                              color: CustomColors.alertRed.withOpacity(0.6),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  history.details,
                                  style: TextStyle(
                                      fontFamily: "Georgia",
                                      fontSize: 18.0,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'At: ${DateUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(history.createdAt))}',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  history.type == 0
                                      ? "Order Debit"
                                      : history.type == 1
                                          ? "Order Credit"
                                          : history.type == 2
                                              ? "Store Offer"
                                              : "Offer",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: CustomColors.alertRed
                                          .withOpacity(0.7),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              '${history.amount}/-',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            widget = Container(
              padding: EdgeInsets.all(10),
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "No Transactions Found",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          widget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AsyncWidgets.asyncError(),
          );
        } else {
          widget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AsyncWidgets.asyncWaiting(),
          );
        }

        return Card(
          color: CustomColors.lightGrey,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.all_inclusive,
                  size: 35.0,
                  color: CustomColors.alertRed,
                ),
                title: Text(
                  "Transaction History",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.green,
                    fontSize: 17.0,
                  ),
                ),
              ),
              Divider(
                color: CustomColors.alertRed,
              ),
              widget,
            ],
          ),
        );
      },
    );
  }
}

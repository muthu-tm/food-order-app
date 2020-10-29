import 'package:chipchop_buyer/db/models/product_faqs.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductFAQsWidget extends StatelessWidget {
  ProductFAQsWidget(this.productID);

  final String productID;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Text(
              "Have a Question?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: FlatButton.icon(
              onPressed: () {},
              icon: Icon(FontAwesomeIcons.edit,
                  size: 25, color: CustomColors.blue),
              label: Text(
                "Ask Here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: CustomColors.blue),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          getFAQs(context),
        ],
      ),
    );
  }

  Widget getFAQs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ProductFaqs().streamAllFAQs(productID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = ListView.builder(
              scrollDirection: Axis.vertical,
              primary: true,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Column(
                    children: [],
                  ),
                );
              },
            );
          } else {
            children = Text(
              "Empty",
              style: TextStyle(fontSize: 14, color: CustomColors.blue),
            );
          }
        } else if (snapshot.hasError) {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }

        return children;
      },
    );
  }
}

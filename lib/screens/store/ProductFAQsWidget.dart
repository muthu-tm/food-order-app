import 'package:chipchop_buyer/db/models/product_faqs.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductFAQsWidget extends StatelessWidget {
  ProductFAQsWidget(this.productID);

  final String productID;

  TextEditingController _feedbackController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    _feedbackController.text = "";

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
              onPressed: () {
                getQuestionDialog(context);
              },
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

  getQuestionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Question:"),
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
                        onPressed: () async {
                          if (_feedbackController.text.trim().isEmpty) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: 'Nothing to ask',
                                backgroundColor: Colors.black,
                                textColor: Colors.white);
                            return;
                          }

                          ProductFaqs faq = ProductFaqs();
                          faq.question = _feedbackController.text;
                          faq.questionedAt =
                              DateTime.now().millisecondsSinceEpoch;
                          try {
                            await faq.create(productID);
                            Navigator.pop(context);
                          } catch (err) {
                            Fluttertoast.showToast(
                                msg: 'Unabe to ask now!',
                                backgroundColor: CustomColors.alertRed,
                                textColor: Colors.white);
                          }
                        },
                        child: Text("Submit"),
                        color: CustomColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                        color: CustomColors.alertRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              primary: false,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                ProductFaqs _faq =
                    ProductFaqs.fromJson(snapshot.data.documents[index].data);
                return Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Q. ',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.black),
                          ),
                          TextSpan(
                            text: '${_faq.question}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.black),
                          ),
                        ]),
                      ),
                      _faq.answer != null && _faq.answer.isNotEmpty
                          ? RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'A. ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.black),
                                ),
                                TextSpan(
                                  text: '${_faq.answer}',
                                  style: TextStyle(
                                      fontSize: 16, color: CustomColors.black),
                                ),
                              ]),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _faq.userName,
                              style: TextStyle(
                                  fontSize: 12, color: CustomColors.grey),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 15,
                              width: 1,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              DateUtils.formatDateTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                    _faq.questionedAt),
                              ),
                              style: TextStyle(
                                  fontSize: 12, color: CustomColors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          } else {
            children = Text(
              "No Q & A found !!",
              style: TextStyle(fontSize: 16, color: CustomColors.blue),
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

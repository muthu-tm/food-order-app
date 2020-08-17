import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.mfinBlue,
        title: SearchBarWidget(
          performSearch: null,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                "or",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              RaisedButton(
                color: CustomColors.mfinBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: CustomColors.mfinButtonGreen)),
                onPressed: () {},
                child: Text(
                  "Nearby stores in map",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }
}

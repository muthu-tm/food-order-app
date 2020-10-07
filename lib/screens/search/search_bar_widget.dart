import 'package:chipchop_buyer/screens/search/SearchAppBar.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchAppBar(),
                settings: RouteSettings(name: '/search/type'),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.search,
                color: CustomColors.blueGreen,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "Search for an Item or Store",
                style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 16,
                    color: Colors.blueGrey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

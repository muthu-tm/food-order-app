import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {

  const SearchBarWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              child: Icon(
                Icons.search,
                color: CustomColors.blueGreen,
              ),
              onTap: () {},
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.blueGrey[500]),
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.blueGrey[500]),
                    border: InputBorder.none,
                    hintText: "Search for an item or store"),
                onSubmitted: (String place) {
                  if (place.isNotEmpty) {
                    //performSearch(place);
                  }
                },
              ),
            ),
            InkWell(
              onTap: () {},
              child: Icon(
                Icons.filter_list,
                color: CustomColors.blueGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

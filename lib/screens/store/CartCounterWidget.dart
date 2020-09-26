import 'package:flutter/material.dart';

import '../utils/CustomColors.dart';

class CartCounter extends StatefulWidget {
  @override
  _CartCounterState createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  int numOfItems = 0;
  @override
  Widget build(BuildContext context) {
    return numOfItems == 0
        ? Container(
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  numOfItems = 1;
                });
              },
              child: Text("Add"),
            ),
          )
        : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildOutlineButton(
                  icon: Icons.remove,
                  press: () {
                    setState(() {
                      numOfItems--;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25 / 2),
                  child: Text(
                    numOfItems.toString().padLeft(2, "0"),
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        color: CustomColors.blue,
                        fontSize: 17),
                  ),
                ),
                buildOutlineButton(
                    icon: Icons.add,
                    press: () {
                      setState(() {
                        numOfItems++;
                      });
                    }),
              ],
            ),
          );
  }

  SizedBox buildOutlineButton({IconData icon, Function press}) {
    return SizedBox(
      width: 35,
      height: 35,
      child: OutlineButton(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: press,
        child: Icon(icon),
      ),
    );
  }
}

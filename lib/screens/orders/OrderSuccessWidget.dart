import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class OrderSuccessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      content: Container(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 96,
              color: CustomColors.green,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Your order successfull!",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Your can track the order status in 'Orders' menu!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CustomColors.blue,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 50.0,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersHomeScreen(),
                      settings: RouteSettings(name: '/orders'),
                    ),
                  );
                },
                child: Text(
                  "Track Order",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: CustomColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            FlatButton(
              child: Text("Go to Home"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                    settings: RouteSettings(name: '/'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

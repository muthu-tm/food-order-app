import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreProfileWidget extends StatelessWidget {
  StoreProfileWidget(this.store);

  final Map<String, String> tempCollectionDays = {
    "0": "Sun",
    "1": "Mon",
    "2": "Tue",
    "3": "Wed",
    "4": "Thu",
    "5": "Fri",
    "6": "Sat",
  };

  final Store store;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              FontAwesomeIcons.store,
              color: CustomColors.green,
            ),
            title: Text(
              "Name",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            leading: Text(""),
            title: Text(
              store.name,
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 13.0,
                  fontFamily: "Georgia"),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.addressCard,
              color: CustomColors.green,
            ),
            title: Text(
              "Address",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            leading: Text(""),
            title: Text(
              store.address.toString(),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 13.0,
                  fontFamily: "Georgia"),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.mobileAlt,
              color: CustomColors.green,
            ),
            title: Text(
              "Contacts",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 60.0),
            child: Container(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                primary: false,
                mainAxisSpacing: 10,
                children: List.generate(
                  store.contacts.length,
                  (index) {
                    return Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CustomColors.white),
                            child: RawMaterialButton(
                              onPressed: () {
                                print("Contact Click");
                              },
                              shape: CircleBorder(),
                              child: Icon(FontAwesomeIcons.image,
                                  color: CustomColors.blue),
                            ),
                          ),
                          Text(
                            store.contacts[index].contactName,
                            style: TextStyle(
                                color: CustomColors.black,
                                fontFamily: 'Georgia'),
                          ),
                          Text(
                            store.contacts[index].contactNumber.toString(),
                            style: TextStyle(
                                color: CustomColors.black,
                                fontFamily: 'Georgia'),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.calendarCheck,
              color: CustomColors.green,
            ),
            title: Text(
              "Available Days",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CustomColors.grey, width: 1.0),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: selectedDays.toList(),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.businessTime,
              color: CustomColors.green,
            ),
            title: Text(
              "Active From: ",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              store.activeFrom.padLeft(2, '0'),
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 14.0,
                  fontFamily: "Georgia"),
            ),
          ),
          ListTile(
            leading: Text(""),
            title: Text(
              "Active Till: ",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              store.activeTill.padLeft(2, '0'),
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 14.0,
                  fontFamily: "Georgia"),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.truck,
              color: CustomColors.green,
            ),
            title: Text(
              "Delivery Details",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 60.0),
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    "Delivery From:",
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                  trailing: Text(
                    store.deliveryDetails.deliveryFrom,
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Delivery Till:",
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                  trailing: Text(
                    store.deliveryDetails.deliveryTill,
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Max Distance:",
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                  trailing: Text(
                    '${store.deliveryDetails.maxDistance.toString()} km',
                    style: TextStyle(
                        color: CustomColors.black, fontFamily: 'Georgia'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get selectedDays sync* {
    for (MapEntry days in tempCollectionDays.entries) {
      yield Transform(
        transform: Matrix4.identity()..scale(0.9),
        child: ChoiceChip(
          label: Text(days.value),
          selected: store.workingDays.contains(int.parse(days.key)),
          elevation: 5.0,
          selectedColor: CustomColors.blue,
          backgroundColor: CustomColors.white,
          labelStyle: TextStyle(color: CustomColors.green),
        ),
      );
    }
  }
}

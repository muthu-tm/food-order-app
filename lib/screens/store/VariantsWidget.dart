import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ProductVariantsWidget extends StatefulWidget {
  ProductVariantsWidget(this.product, this.widgetType);

  final Products product;
  // 0 - Row, 1 - Column
  final int widgetType;
  @override
  _ProductVariantsWidgetState createState() => _ProductVariantsWidgetState();
}

class _ProductVariantsWidgetState extends State<ProductVariantsWidget> {
  String dropdownValue = "0";
  @override
  Widget build(BuildContext context) {
    return widget.widgetType == 0
        ? Row(
            children: (widget.product.variants.length == 1)
                ? getSingleDetails()
                : getDropDownDetails(),
          )
        : Column(
            children: (widget.product.variants.length == 1)
                ? getSingleDetails()
                : getDropDownDetails(),
          );
  }

  List<Widget> getDropDownDetails() {
    return [
      Container(
        height: 25,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        // dropdown below..
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: CustomColors.green,
          ),
          iconSize: 30,
          underline: SizedBox(),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: List.generate(widget.product.variants.length, (int index) {
            return DropdownMenuItem(
              value: widget.product.variants[index].id,
              child: Container(
                child: Text(
                  "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      SizedBox(width: 10),
      Text(
        " ₹ ${widget.product.variants[int.parse(dropdownValue)].currentPrice.toString()}",
        style: TextStyle(
          color: CustomColors.black,
          fontSize: 12.0,
        ),
      )
    ];
  }

  List<Widget> getSingleDetails() {
    return [
      Container(
        height: 25,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Text(
          "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
          style: TextStyle(
            color: CustomColors.black,
            fontSize: 13.0,
          ),
        ),
      ),
      SizedBox(width: 10),
      Text(
        " ₹ ${widget.product.variants[int.parse(dropdownValue)].currentPrice.toString()}",
        style: TextStyle(
          color: CustomColors.black,
          fontSize: 12.0,
        ),
      )
    ];
  }
}

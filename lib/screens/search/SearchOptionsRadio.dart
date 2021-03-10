import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchOptionsRadio extends StatelessWidget {
  SearchOptionsRadio(this._item, this._color);

  final CustomRadioModel _item;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Container(
        height: 35.0,
        width: 100,
        child: Center(
          child: Text(
            _item.buttonText,
            style: TextStyle(
                
                color:
                    _item.isSelected ? CustomColors.white : CustomColors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 13.0),
          ),
        ),
        decoration: BoxDecoration(
          color: _item.isSelected ? _color : CustomColors.lightGrey,
          border: Border.all(
              width: 1.0,
              color: _item.isSelected
                  ? CustomColors.blueGreen
                  : CustomColors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}

class CustomRadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  CustomRadioModel(this.isSelected, this.buttonText, this.text);
}

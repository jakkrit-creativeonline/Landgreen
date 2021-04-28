import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';

class DropDown extends StatelessWidget {
  const DropDown({
    Key key,
    this.onChange,
    this.items,
    this.labelText = '',
    this.hintText,
    this.value,
    this.validator,
    this.onTap,
    this.fromPage='',
  }) : super(key: key);
  final Function onChange;
  final List items;
  final String hintText;
  final value;
  final Function validator;
  final Function onTap;
  final String fromPage;
  final String labelText;

  DropdownMenuItem<String> getDropDownWidget(
      Map<String, dynamic> map, String value, String text,
      {String normalText = '', String price = ''}) {
    // print('map[text] =>${map[text]} ->${map[value]}');
    return DropdownMenuItem<String>(
        value: map[value].toString(),
        child: (normalText == '' && price == '')
            ? Column(
              children: [
                Text(map[text]),
                Divider(
                  height: 1.0,
                  color: Colors.grey,
                  thickness: 1.0,
                ),
              ],
            )
            : Column(
            mainAxisSize: MainAxisSize.max,
              children: [
                Text(map[text] +
                    " " +
                    normalText +
                    " " +
                    map[price].toString().split('.')[0]),
                Divider(
                  height: 1.0,
                  color: Colors.grey,
                  thickness: 1.0,
                ),
              ],
            ));
  }

  DropdownMenuItem<String> getSearchableDropDown(Map<String, dynamic> map,
      String value1, String value2, String text1, String text2) {
    return DropdownMenuItem<String>(
        value: map[value1] + " " + map[value2],
        child: Text(map[text1] + " " + map[text2]));
  }

  // DropdownMenuItem<String> getSearchableDropDownWidget(
  //     Map<String, dynamic> map, String value1, String value2) {
  //   return DropdownMenuItem<String>(
  //       value: map[value1] + " " + map[value2],
  //       child: Text(map[value1] + " " + map[value2]));
  // }

  @override
  Widget build(BuildContext context) {
    if(fromPage == ''){
      return Container(
        padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
        child: DropdownButtonFormField(
            hint: Text(hintText),
            isExpanded: true,
            isDense: false,
            value: value,
            onTap: onTap,
            decoration: InputDecoration(

                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                ),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                filled: true,
                labelText: labelText,
                fillColor: Colors.white),
            validator: validator,
            items: items,
            autofocus: false,
            onChanged: onChange),
      );
    }else{
      print('Drop downFrom Page CEO');
      return Container(
        padding: const EdgeInsets.only(top: 10, right: 5,left: 5, bottom: 10),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 2,color: subFontColor),
              bottom: BorderSide(width: 2,color: subFontColor),
            )
          ),
          child: DropdownButtonFormField(
              hint: Text(hintText),
              isExpanded: true,
              isDense: true,
              value: value,
              onTap: onTap,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10,top: -10,bottom: 0,right: 10),
                  filled: true,
                  fillColor: Color(0xFFE6E6E6),

              ),
              validator: validator,
              items: items,
              autofocus: false,
              onChanged: onChange),
        ),
      );
    }

  }
}

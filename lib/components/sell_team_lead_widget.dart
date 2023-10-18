import 'package:flutter/material.dart';
import 'package:system/components/team_label.dart';
import 'package:system/configs/constants.dart';

class SellTeamLead extends StatelessWidget {
  const SellTeamLead({
    Key key,
    @required this.lv_red,
    @required this.lv_yellow,
    @required this.lv_orange,
  }) : super(key: key);

  final String lv_red;
  final String lv_yellow;
  final String lv_orange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (lv_red != '--' && lv_red != '')
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sub. : ${lv_red}',
                      style: TextStyle(
                        fontSize: 18,
                        color: subFontColor,
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        (lv_yellow != '--' && lv_yellow != '')
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผจก. : ${lv_yellow}',
                      style: TextStyle(
                        fontSize: 18,
                        color: subFontColor,
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ผอ. : ${lv_orange}',
                style: TextStyle(
                  fontSize: 18,
                  color: subFontColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

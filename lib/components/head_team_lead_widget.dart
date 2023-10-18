import 'package:system/components/team_label.dart';
import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';

class HeadTeamLead extends StatelessWidget {
  const HeadTeamLead({
    Key key,
    @required this.lv_yellow,
    @required this.lv_orange,
  }) : super(key: key);

  final String lv_yellow;
  final String lv_orange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ผจก. : ${lv_yellow}',
                style: TextStyle(
                  fontSize: 18,
                  color: subFontColor,
                ),
              ),
              Text('ผอ. : ${lv_orange}',
                style: TextStyle(
                  fontSize: 18,
                  color: subFontColor,
                ),
              ),
            ],
          ),
        ),
        // TeamLabel(
        //   color: Colors.yellow,
        //   text: '${lv_yellow}',
        // ),
        // TeamLabel(
        //   color: Colors.orange,
        //   text: '${lv_orange}',
        // ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:system/components/team_label.dart';
import 'package:system/configs/constants.dart';

class SubMenagerTeamLead extends StatelessWidget {
  const SubMenagerTeamLead({
    Key key,
    @required this.lv_orange,
  }) : super(key: key);

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
              Text('ผอ. : ${lv_orange}',
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

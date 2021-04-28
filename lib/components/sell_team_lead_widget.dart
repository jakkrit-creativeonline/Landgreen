
import 'package:flutter/material.dart';
import 'package:system/components/team_label.dart';

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
        (lv_red!='--' && lv_red !=''  )?TeamLabel(
          color: Color(0xFFD42219),
          text: 'สีแดง / ${lv_red}',
        ):Container(),
        (lv_yellow!='--' && lv_yellow !=''  )?TeamLabel(
          color: Color(0xFFF9BE19),
          text: 'สีเหลือง / ${lv_yellow}',
        ):Container(),
        TeamLabel(
          color: Color(0xFFF15A24),
          text: 'สีส้ม / ${lv_orange}',
        ),
      ],
    );
  }
}

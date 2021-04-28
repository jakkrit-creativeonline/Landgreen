import 'package:system/components/team_label.dart';
import 'package:flutter/material.dart';

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
        TeamLabel(
          color: Colors.yellow,
          text: '${lv_yellow}',
        ),
        TeamLabel(
          color: Colors.orange,
          text: '${lv_orange}',
        ),
      ],
    );
  }
}

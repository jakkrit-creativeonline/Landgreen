import 'package:flutter/material.dart';
import 'package:system/components/team_label.dart';

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
        TeamLabel(
          color: Colors.orange,
          text: '${lv_orange}',
        ),
      ],
    );
  }
}

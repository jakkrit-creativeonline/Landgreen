import 'package:charts_flutter/flutter.dart' as charts;

class TeamGoal {
  final String text;
  final int total;
  final charts.Color color;

  TeamGoal(this.color, this.text, this.total);
}

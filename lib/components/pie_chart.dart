import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class HalfDonut extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final String formPage;

  HalfDonut(this.seriesList, {this.animate,this.formPage});

  factory HalfDonut.simpleData() {
    return HalfDonut(
      _createSimple(),
      animate: false,
    );
  }

  static List<charts.Series<TeamGoal, String>> _createSimple() {
    Map<String, TeamGoal> chartData;

    chartData = {
      'sell':
          TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', 0),
      'goal': TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 100)
    };

    return [
      charts.Series(
        id: 'teamgoal',
        domainFn: (TeamGoal data, i) => data.text,
        measureFn: (TeamGoal data, i) => data.total,
        colorFn: (TeamGoal data, i) => data.color,
        labelAccessorFn: (TeamGoal data, u) => data.text,
        data: chartData.values.toList(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    print(formPage);
    if(formPage=='margin5'){
      // print('sss');
      return new charts.PieChart(
        seriesList,
        animate: animate,

        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 35, startAngle: pi, arcLength: pi
        ),
        layoutConfig: new charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(7),
          topMarginSpec: charts.MarginSpec.fixedPixel(7),
          rightMarginSpec: charts.MarginSpec.fixedPixel(7),
          bottomMarginSpec:charts.MarginSpec.fixedPixel(7),
        ),
      );
    }else if(formPage=='margin0'){
      // print('sss');
      return new charts.PieChart(
        seriesList,
        animate: animate,

        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 30, startAngle: pi, arcLength: pi
        ),
        layoutConfig: new charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec:charts.MarginSpec.fixedPixel(0),
        ),
      );
    }
    else{
      return new charts.PieChart(
        seriesList,
        animate: animate,

        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 25, startAngle: pi, arcLength: pi
        ),
      );
    }

  }
}

class CeoPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final bool enableLabel;
  final bool horizontalFirst;

  CeoPieChart(this.seriesList,
      {this.animate, this.enableLabel = false, this.horizontalFirst = false});

  factory CeoPieChart.withSampleData() {
    return new CeoPieChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  static List<charts.Series<TeamGoal, String>> _createSampleData() {
    final data = [
      new TeamGoal(charts.ColorUtil.fromDartColor(grayDarkColor), 'เงินสด', 5),
      new TeamGoal(charts.ColorUtil.fromDartColor(cyanColor), 'เครดิต', 15),
    ];

    return [
      new charts.Series<TeamGoal, String>(
        id: 'Sales',
        domainFn: (TeamGoal sales, _) => sales.text,
        measureFn: (TeamGoal sales, _) => sales.total,
        colorFn: (TeamGoal sales, _) => sales.color,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (enableLabel) {
      return new charts.PieChart(
        seriesList,
        animate: animate,
        behaviors: [
          new charts.DatumLegend(
            position: charts.BehaviorPosition.bottom,
            outsideJustification: charts.OutsideJustification.middleDrawArea,
            horizontalFirst: horizontalFirst,
            desiredMaxRows: 2,
          )
        ],
        layoutConfig: new charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec:charts.MarginSpec.fixedPixel(0),
        ),
        defaultRenderer: new charts.ArcRendererConfig(
            arcRendererDecorators: [new charts.ArcLabelDecorator()]),
      );
    } else {
      return new charts.PieChart(
        seriesList,
        animate: animate,
        //behaviors: [new charts.DatumLegend()],
        layoutConfig: new charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec:charts.MarginSpec.fixedPixel(0),
        ),
      );
    }
  }
}
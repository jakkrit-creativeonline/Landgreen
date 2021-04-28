import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class HorizontalBarLabelCustomChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarLabelCustomChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  static HorizontalBarLabelCustomChart createWithSampleData() {
    return new HorizontalBarLabelCustomChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory HorizontalBarLabelCustomChart.withRandomData() {
    return new HorizontalBarLabelCustomChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<TeamGoal, String>> _createRandomData() {
    Map<String, TeamGoal> chartData;

    chartData = {
      'sell':
          TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', 120),
      'goal': TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 100)
    };

    return [
      charts.Series(
          id: 'sale',
          domainFn: (TeamGoal data, i) => data.text,
          measureFn: (TeamGoal data, i) => data.total,
          colorFn: (TeamGoal data, i) => data.color,
          data: chartData.values.toList())
    ];

    //final random = new Random();

    // final data = [
    //   new SaleRanking('2014', random.nextInt(100)),
    //   new SaleRanking('2015', random.nextInt(100)),
    //   new SaleRanking('2016', random.nextInt(100)),
    //   new SaleRanking('2017', random.nextInt(100)),
    // ];

    // return [
    //   new charts.Series<SaleRanking, String>(
    //     id: 'Sales',
    //     domainFn: (SaleRanking sales, _) => sales.year,
    //     measureFn: (SaleRanking sales, _) => sales.sales,
    //     data: data,
    //     // Set a label accessor to control the text of the bar label.
    //     labelAccessorFn: (SaleRanking sales, _) =>
    //         '${sales.year}: \$${sales.sales.toString()}',
    //     insideLabelStyleAccessorFn: (SaleRanking sales, _) {
    //       final color = (sales.year == '2014')
    //           ? charts.MaterialPalette.red.shadeDefault
    //           : charts.MaterialPalette.yellow.shadeDefault.darker;
    //       return new charts.TextStyleSpec(color: color);
    //     },
    //     outsideLabelStyleAccessorFn: (SaleRanking sales, _) {
    //       final color = (sales.year == '2014')
    //           ? charts.MaterialPalette.red.shadeDefault
    //           : charts.MaterialPalette.yellow.shadeDefault.darker;
    //       return new charts.TextStyleSpec(color: color);
    //     },
    //   ),
    // ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  // The [BarLabelDecorator] has settings to set the text style for all labels
  // for inside the bar and outside the bar. To be able to control each datum's
  // style, set the style accessor functions on the series.
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // primaryMeasureAxis:
      //     new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
      // domainAxis: new charts.OrdinalAxisSpec(
      //     // Make sure that we draw the domain axis line.
      //     showAxisLine: false,
      //     // But don't draw anything else.
      //     renderSpec: new charts.NoneRenderSpec()),
      //barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      // domainAxis:
      //     new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<SaleRanking, String>> _createSampleData() {
    final data = [
      new SaleRanking(
          1, 175, 'กนกนุช', charts.ColorUtil.fromDartColor(kPrimaryColor)),
      new SaleRanking(
          2, 170, 'อิศ', charts.ColorUtil.fromDartColor(kPrimaryColor)),
      new SaleRanking(
          3, 95, 'กกกก', charts.ColorUtil.fromDartColor(kPrimaryColor)),
      new SaleRanking(
          4, 89, 'กนพิเชษษกนุช', charts.ColorUtil.fromDartColor(kPrimaryColor)),
    ];

    return [
      new charts.Series<SaleRanking, String>(
        id: 'Sales',
        domainFn: (SaleRanking sales, _) => sales.rank.toString(),
        measureFn: (SaleRanking sales, _) => sales.total,
        data: data,
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (SaleRanking sales, _) =>
            '${sales.total.toString()} กระสอบ',
        insideLabelStyleAccessorFn: (SaleRanking sales, _) {
          final color = charts.MaterialPalette.black;
          return new charts.TextStyleSpec(color: color, fontFamily: 'DB');
        },
      ),
    ];
  }
}

/// Sample ordinal data type.
class SaleRanking {
  final int rank;
  final int total;
  final String name;
  final charts.Color color;
  final Color legendColor;
  final String imgAvatar;

  SaleRanking(this.rank, this.total, this.name, this.color,
      {this.legendColor = kPrimaryColor, this.imgAvatar = ''});
}

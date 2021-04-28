import 'package:cached_network_image/cached_network_image.dart';
import 'package:system/components/horizontal_bar_chart.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartRanking extends StatelessWidget {
  final series;
  final legenData;

  const ChartRanking({Key key, this.series, this.legenData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List legend = legenData.values.toList();
    print("size.height ${size.width}");
    double ratioScreen = 0.0;
    if(size.width <=375){
      ratioScreen = -0.05;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (legenData != null)
          GridView.count(
              shrinkWrap: true,
              primary: false,
              crossAxisCount: 6,
              childAspectRatio: 0.9+ratioScreen,
              children: List.generate(
                  legend.length, (index) {
                var result = legend[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: CachedNetworkImageProvider(
                          '$storagePath/${result.imgAvatar}'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: result.legendColor),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text('อันดับ ${result.rank} '),
                      ],
                    ),
                    Text('${result.name}',style: TextStyle(fontSize: 12),overflow: TextOverflow.ellipsis,)
                  ],
                );
              })),
        Container(
          width: size.width,
          height: (legend.length<3)?150:300,
          child: HorizontalBarLabelCustomChart(series, animate: true),
        ),
      ],
    );
  }
}

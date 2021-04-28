import 'dart:convert';
import 'dart:ui';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/screens/ceo/components/ceo_map_detail.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:touchable/touchable.dart';
import 'package:http/http.dart' as http;

class CeoMapTest extends StatefulWidget {
  @override
  _CeoMapTestState createState() => _CeoMapTestState();
}

class _CeoMapTestState extends State<CeoMapTest> {
  Future<List> showData;
  String selectedReport = '2021-01';

  Future<List> fetchShowData() async {
    final res = await http.post('$apiPath-ceo',
        body: {'func': 'getCacheProvinceRanking', 'namefile': selectedReport});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load province ranking');
    }
  }

  Future getData() async {
    showData = fetchShowData();
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
          future: showData,
          builder: (context, snap) {
            if (snap.hasData) {
              print('has data');
              return Container(
                height: 500,
                child: ListView.builder(
                    itemCount: snap.data.length,
                    itemBuilder: (bc, i) {
                      var result = snap.data[i];
                      print(i);
                      return Card(
                        child: Column(
                          children: [
                            Text('อันดับ ${i + 1}'),
                            Text('จังหวัด${result['PROVINCE_NAME']}'),
                            Text(
                                'เงินสด ${result['cash_count_product_cat1']} กระสอบ'),
                            Text(
                                'เครดิต ${result['credit_count_product_cat1']} กระสอบ'),
                            Text(
                                'รวม ${result['sum_count_product_cat1']} กระสอบ'),
                          ],
                        ),
                      );
                    }),
              );
            } else if (snap.hasError) {
              print('has error');
              return Text('${snap.error}');
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

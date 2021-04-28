import 'dart:convert';

import 'package:system/configs/constants.dart';
import 'package:http/http.dart';

class GetReport {
  var client = Client();

  Future<String> getDefaultReoprt() async {
    DateTime n = DateTime.now();
    print('DateTime.now()=>${n}');
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }

  Future getCeoSaleRanking() async {
    var body = {'func': 'getCacheSaleRanking'};
    var res = await client.post('$apiPath-ceo', body: body);
    print('getCeoSaleRanking');
    print(res.body);
    List data = jsonDecode(res.body);
    int lastRank = data.length;
    List saleRankData = [];
    data.sort((a, b) => b['sumcountcat'] - a['sumcountcat']);
    for (int i = 0; i < data.length; i++) {
      if (i < 5) {
        data[i]['rank'] = i + 1;
        saleRankData.add(data[i]);
      } else {
        data[data.length - 1]['rank'] = lastRank;
        saleRankData.add(data[data.length - 1]);
        break;
      }
    }
    Sqlite().insertJson('SaleRanking', '1', res.body);
    Sqlite().insertJson(
        'CEO_SALE_RANKINKG', 'CEO_SALE_RANKINKG', jsonEncode(saleRankData));
    return saleRankData;
  }

  Future getCeoCarRanking({selectedReport = ''}) async {
    if (selectedReport == '') selectedReport = await getDefaultReoprt();
    var body = {'func': 'getCacheCarRanking', 'namefile': selectedReport};
    var res = await client.post('$apiPath-ceo', body: body);
    Sqlite().insertJson('CEO_CAR_RANKING', selectedReport, res.body);
    return res.body;
  }

  Future getCeoTeamRanking({selectedReport = ''}) async {
    if (selectedReport == '') selectedReport = await getDefaultReoprt();
    var body = {'func': 'getCacheCarRanking', 'namefile': selectedReport};
    print(body);
    var res = await client.post('$apiPath-ceo', body: body);
    if(res.body !='{}'){
      List data = jsonDecode(res.body);
      int lastRank = data.length;
      List managerRank = [];
      data.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
      for (int i = 0; i < data.length; i++) {
        if (i < 5) {
          data[i]['rank'] = i + 1;
          managerRank.add(data[i]);
        } else {
          data[data.length - 1]['rank'] = lastRank;
          managerRank.add(data[data.length - 1]);
          break;
        }
      }
      Sqlite()
          .insertJson('CEO_TEAM_RANK', selectedReport, jsonEncode(managerRank));
      return managerRank;
    }else{
      return [];
    }

  }

  Future getCeoManagerRank({selectedReport = ''}) async {
    if (selectedReport == '') selectedReport = await getDefaultReoprt();
    var body = {'func': 'get_manage_rank_data', 'namefile': selectedReport};
    print(body);
    var res = await client.post('$apiPath-ceo', body: body);
    if(res.body !='{}'){
      List data = jsonDecode(res.body);
      int lastRank = data.length;
      List managerRank = [];
      data.sort(
              (a, b) => b['sum_count_product_cat1'] - a['sum_count_product_cat1']);
      for (int i = 0; i < data.length; i++) {
        if (i < 5) {
          data[i]['rank'] = i + 1;
          managerRank.add(data[i]);
        } else {
          data[data.length - 1]['rank'] = lastRank;
          managerRank.add(data[data.length - 1]);
          break;
        }
      }
      Sqlite().insertJson(
          'CEO_MANAGER_RANK', selectedReport, jsonEncode(managerRank));
      return managerRank;
    }else{
      return [];
    }

  }

  Future getCeoManagerRankDetail({selectedReport = ''}) async {
    if (selectedReport == '') selectedReport = await getDefaultReoprt();
    var body = {
      'func': 'get_data_report_manager_rank',
      'namefile': selectedReport
    };
    print(body);
    var res = await client.post('$apiPath-ceo', body: body);
    Sqlite().insertJson('CEO_MANAGER_RANK_DETAIL', selectedReport, res.body);
    return res.body;
  }

  Future getCeoMap({selectedReport = ''}) async {
    if (selectedReport == '') selectedReport = await getDefaultReoprt();
    var body = {'func': 'getCacheProvinceRanking', 'namefile': selectedReport};
    print(body);
    var res = await client.post('$apiPath-ceo', body: body);
    print(res);
    if (res.body != '{}') {
      Sqlite().insertJson('CEO_PROVINCE_RANKING', selectedReport, res.body);
      return res.body;
    }
  }

  Future getCeoIncome(
      {noResult = false, selectedReport = '98', isThisMonth = true}) async {
    if (isThisMonth) {
      var body = {
        'func': 'getBillReportThisMonth',
        'monthSelect': selectedReport
      };
      var res = await client.post('$apiPath-ceo', body: body);
      Sqlite().insertJson('CEO_INCOME_THIS_MONTH', selectedReport, res.body);
      if (!noResult) return res.body;
    } else {
      var body = {
        'func': 'getBillReportBeforeMonth',
        'monthSelect': selectedReport
      };
      var res = await client.post('$apiPath-ceo', body: body);
      Sqlite().insertJson('CEO_INCOME_BEFORE_MONTH', selectedReport, res.body);
      if (!noResult) return res.body;
    }
  }

  Future getCeoTopTeam({noResult = false}) async {
    var body = {'func': 'getCacheTopTeam'};
    var res = await client.post('$apiPath-accounts', body: body);
    Sqlite().insertJson('CEO_TOP_TEAM', '1', res.body);
    if (!noResult) {
      return res.body;
    }
  }

  Future getCeoTopSale({noResult = false}) async {
    var body = {'func': 'getCacheTopSale'};
    var res = await client.post('$apiPath-accounts', body: body);
    Sqlite().insertJson('CEO_TOP_SALE', '1', res.body);
    if (!noResult) {
      return res.body;
    }
  }

  Future getCreditReportCar({noResult = false, selectedMonth = ''}) async {
    var body = {
      'func': 'reportCreditPerCar',
      'changeMonthSelect': selectedMonth
    };
    var res = await client.post('$apiPath-credit', body: body);
    Sqlite().insertJson('CEO_CREDIT_REPORT_CAR', selectedMonth, res.body);
    if (!noResult) {
      return res.body;
    }
  }

  Future getCreditReportManager({noResult = false, selectedMonth = ''}) async {
    var body = {
      'func': 'reportCreditPerManager',
      'changeMonthSelect': selectedMonth
    };
    var res = await client.post('$apiPath-credit', body: body);
    Sqlite().insertJson('CEO_CREDIT_REPORT_MANAGER', selectedMonth, res.body);
    if (!noResult) {
      return res.body;
    }
  }

  Future getCreditReportManagerDetail(
      {noResult = false, selectedMonth = '', id}) async {
    var body = {
      'func': 'reportCreditPerYellow',
      'changeMonthSelect': selectedMonth,
      'manager_id': '$id'
    };
    var res = await client.post('$apiPath-credit', body: body);
    Sqlite()
        .insertJson('CEO_CREDIT_REPORT_MANAGER_$id', selectedMonth, res.body);
    if (!noResult) {
      return res.body;
    }
  }

  Future getPTA({noResult = false, selectedMonth = '', id}) async {
    var body = {
      'func': 'getDocPTAApprovedPerSale',
      'Sale_id': '$id',
    };
    var res = await client.post('$apiPath-credit-doc', body: body);
    Sqlite().insertJson('DOC_PTA_FOR_USER_$id', selectedMonth, res.body);
    if (!noResult) {
      return res.body;
    }
  }


}

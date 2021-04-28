import 'package:pdf/widgets.dart';

class FormatMethod {

  ConvertToThaiBath(var number){
    var n;
    if(number >= 10000.00 && number < 100000.00){
      n = (number/10000.00).toStringAsFixed(1);
      return [n,'หมื่นบาท'];
    }else if(number >= 100000.00 && number < 1000000.00) {
      n = (number/100000.00).toStringAsFixed(1);
      return [n,'แสนบาท'];
    }else if(number >= 1000000.00) {
      n = (number/1000000.00).toStringAsFixed(1);
      return [n,'ล้านบาท'];
    }else if(number >= 10000000.00) {
      n = (number/10000000.00).toStringAsFixed(1);
      return [n,'สิบล้านบาท'];
    }else if(number >= 100000000.00) {
      n = (number/100000000.00).toStringAsFixed(1);
      return [n,'ร้อยล้านบาท'];
    }else if(number >= 1000000000.00) {
      n = (number/1000000000.00).toStringAsFixed(1);
      return [n,'พันล้านบาท'];
    }else if(number >= 10000000000.00) {
      n = (number/10000000000.00).toStringAsFixed(1);
      return [n,'ล้านล้านบาท'];
    }else{
      return [number.toString(),'บาท'];
    }
  }

  SeperateNumber(var number) {
    if(number.runtimeType == double){
       number =number.toStringAsFixed(2);
    }
    var n = number.toString();
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function mathFunc = (Match match) => '${match[1]},';
    String result = n.replaceAllMapped(reg, mathFunc);
    return result;
  }

  DateFormat(DateTime date) {
    var d = date.day;
    var y = date.year;
    var m = date.month;
    return y.toString() +
        '-' +
        m.toString().padLeft(2, '0') +
        '-' +
        d.toString().padLeft(2, '0');
  }

  DateTimeFormat(var date) {
    return date.toString().split('.')[0];
  }



  PadLeft(var str) {
    var StrString;
    if (str.runtimeType != String) {
      StrString = str.toString();
    } else {
      StrString = str;
    }
    return StrString.padLeft(2, '0');
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  ThaiFormat(String date) {
    List month = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    var tmp = date.split('-');

    /// Thai Date Format 01 พ.ย. 2563
    return tmp[2] +
        ' ' +
        month[int.parse(tmp[1])] +
        ' ' +
        (int.parse(tmp[0]) + 543).toString();
  }

  ThaiDateFormat(String date) {
    var listDate = date.split('-');
    var now = new DateTime(int.parse(listDate[0].toString()),
        int.parse(listDate[1].toString()), int.parse(listDate[2].toString()));
    var thaiMonth = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    var result = '${now.day}/${thaiMonth[now.month]}/${now.year + 543}';
    return result;
  }

  ThaiMonthFormat(String date) {
    var listDate = date.split('-');
    var now = new DateTime(int.parse(listDate[0].toString()),
        int.parse(listDate[1].toString()), int.parse(listDate[2].toString()));
    var thaiMonth = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    var result = '${thaiMonth[now.month]} ${now.year + 543}';
    return result;
  }

  ThaiDateTimeFormat(String date) {
    // print(date);
    var listDate = date.split('-');
    // var now = new DateTime(int.parse(listDate[0].toString()),
    //     int.parse(listDate[1].toString()), int.parse(listDate[2].toString()));
    var now =  DateTime.parse(date);
    var thaiMonth = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    var result = '${now.day} ${thaiMonth[now.month]} ${now.year + 543} เวลา ${now.hour}:${now.minute} น.';
    return result;
  }


}

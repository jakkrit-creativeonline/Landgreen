import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'package:system/configs/constants.dart';

class Sqlite {
  final String dbname = 'faarun.db';
  int version = 1;
  FormatMethod f = FormatMethod();

  Sqlite() {
    initDB();
  }

  Future<Null> initDB() async {
    await openDatabase(join(await getDatabasesPath(), dbname),
        onCreate: (db, version) async {
          Batch batch = db.batch();
          batch.execute(sqltext().sqlInitUser);
          batch.execute(sqltext().sqlInitSettingCar);
          batch.execute(sqltext().sqlInitUserMoneyShare);
          batch.execute(sqltext().sqlInitProvice);
          batch.execute(sqltext().sqlInitSaleCommission);
          batch.execute(sqltext().sqlInitAmphur);
          batch.execute(sqltext().sqlInitDistrict);
          batch.execute(sqltext().sqlInitGEO);
          batch.execute(sqltext().sqlInitBILL);
          batch.execute(sqltext().sqlInitTrail);
          batch.execute(sqltext().sqlInitPRODUCT);
          batch.execute(sqltext().sqlInitPRODUCTCANSELL);
          batch.execute(sqltext().sqlInitRECEIPT);
          batch.execute(sqltext().sqlInitCustomerType);
          batch.execute(sqltext().sqlInitImageTable);
          batch.execute(sqltext().sqlInitCustomer);
          batch.execute(sqltext().sqlInitContact);
          batch.execute(sqltext().sqlInitSettingCompany);
          batch.execute(sqltext().sqlInitJsonTable);
          batch.execute(sqltext().sqlInitCategory);
          batch.execute(sqltext().sqlInitStockNotPrice);
          batch.execute(sqltext().sqlInitConditionOpenBillCredit);

          List<dynamic> result = await batch.commit(noResult: true);
          print('Sqlite onCreate result =>${result}');
        },
        version: version,
        onUpgrade: (db, int oldVersion, int newVersion) async {
          print(
              'checkVersion oldVersion=>${oldVersion},newVersion=>${newVersion}');
          Batch batch = db.batch();
          batch.execute(sqltext().sqlInitUser);
          batch.execute(sqltext().sqlInitSettingCar);
          batch.execute(sqltext().sqlInitUserMoneyShare);
          batch.execute(sqltext().sqlInitProvice);
          batch.execute(sqltext().sqlInitSaleCommission);
          batch.execute(sqltext().sqlInitAmphur);
          batch.execute(sqltext().sqlInitDistrict);
          batch.execute(sqltext().sqlInitGEO);
          batch.execute(sqltext().sqlInitBILL);
          batch.execute(sqltext().sqlInitTrail);
          batch.execute(sqltext().sqlInitPRODUCT);
          batch.execute(sqltext().sqlInitPRODUCTCANSELL);
          batch.execute(sqltext().sqlInitRECEIPT);
          batch.execute(sqltext().sqlInitCustomerType);
          batch.execute(sqltext().sqlInitImageTable);
          batch.execute(sqltext().sqlInitCustomer);
          batch.execute(sqltext().sqlInitContact);
          batch.execute(sqltext().sqlInitSettingCompany);
          batch.execute(sqltext().sqlInitJsonTable);
          batch.execute(sqltext().sqlInitCategory);
          batch.execute(sqltext().sqlInitStockNotPrice);
          batch.execute(sqltext().sqlInitConditionOpenBillCredit);
          // batch.commit(noResult: true);
          List<dynamic> result = await batch.commit(noResult: true);
          print('Sqlite onUpgrade result =>${result}');
        });
  }

  Future<Database> connectedDatabase() async {
    return openDatabase(join(await getDatabasesPath(), dbname));
  }

  Future<Null> insertImage(String table, String key, String value) async {
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    var res = await query('IMAGE_TABLE',
        where: 'IMAGE_TABLE = "$table" AND IMAGE_KEY = "$key"', firstRow: true);
    if (res != null) {
      batch.insert(
          'IMAGE_TABLE',
          {
            'ID': '${res['ID']}',
            'IMAGE_TABLE': table,
            'IMAGE_KEY': key,
            'IMAGE_VALUE': value
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      batch.insert('IMAGE_TABLE',
          {'IMAGE_TABLE': table, 'IMAGE_KEY': key, 'IMAGE_VALUE': value},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    batch.commit(noResult: true);
  }

  Future<Null> insertJson(String table, String key, String value) async {
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    var res = await query('JSON_TABLE',
        where: 'DATA_TABLE = "$table" AND JSON_KEY = "$key"', firstRow: true);
    if (res != null) {
      batch.insert(
          'JSON_TABLE',
          {
            'ID': '${res['ID']}',
            'DATA_TABLE': table,
            'JSON_KEY': key,
            'JSON_VALUE': value
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      batch.insert('JSON_TABLE',
          {'DATA_TABLE': table, 'JSON_KEY': key, 'JSON_VALUE': value},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    batch.commit(noResult: true);
  }

//User Provider
  Future<void> insertUser(List user) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    user.forEach((val) {
      batch.insert(
          'USER',
          {
            'ID': val['ID'],
            'Username': val['Username'],
            'Password': val['Password'],
            'Level_id': val['Level_id'],
            'Name': val['Name'],
            'Surname': val['Surname'],
            'Id_card': val['Id_card'],
            'Setting_commission': val['Setting_commission'],
            'Setting_recommend': val['Setting_recommend'],
            'Work_date_start': val['Work_date_start'],
            'Work_team_user_id': val['Work_team_user_id'],
            'Work_manager_user_id': val['Work_manager_user_id'],
            'Work_car_number': val['Work_car_number'],
            'Work_status': val['Work_status'],
            'Work_car_id': val['Work_car_id'],
            'Goal': val['Goal'],
            'Edit_user_id': val['Edit_user_id'],
            'Bank_id': val['Bank_id'],
            'Bank_account': val['Bank_account'],
            'Address': val['Address'],
            'District_id': val['District_id'],
            'Amphur_id': val['Amphur_id'],
            'Province_id': val['Province_id'],
            'Sex': val['Sex'],
            'Birthday': val['Birthday'],
            'User_id_recommend': val['User_id_recommend'],
            'Image': val['Image'],
            'Image_id_card': val['Image_id_card'],
            'Before_after_type': val['Before_after_type'],
            'Setting_commission_percent': val['Setting_commission_percent'],
            'Sales_Province_id': val['Sales_Province_id'],
            'Timestamp': val['Timestamp'],
            'Sale_vip_team_id': val['Sale_vip_team_id'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    batch.commit(noResult: true);
  }

  Future<List<User>> getUser() async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    List<User> user = List();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('USER');

    for (var map in maps) {
      User _data = User.fromJson(map);
      user.add(_data);
    }

    return user;
  }

  Future<Null> insertSettingCompany(List data) async {
    Database db = await connectedDatabase();
    data.forEach((e) {
      db.insert(
          'SETTING_COMPANY',
          {
            "ID": e['ID'],
            "Name": "${e['Name']}",
            "Address": "${e['Address']}",
            "Zip_code": "${e['Zip_code']}",
            "Tax_code": "${e['Tax_code']}",
            "Phone": "${e['Phone']}",
            "Mobile": "${e['Mobile']}",
            "Fax": "${e['Fax']}",
            "Email": "${e['Email']}",
            "Qrcodeimage": "${e['Qrcodeimage']}",
            "Edit_user_id": "${e['Edit_user_id']}",
            "Timestamp": "${e['Timestamp']}",
            "Img_sign_ceo": "${e['Img_sign_ceo']}",
            "Contract_name": "${e['Contract_name']}",
            "Ceo_name": "${e['Ceo_name']}",
            "SName": "${e['SName']}",
            "Seal": "${e['Seal']}",
            "Ceo_Born": "${e['Ceo_Born']}",
            "Ceo_ID_Card": "${e['Ceo_ID_Card']}"
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Null> trailRecord(Map<String, dynamic> billData) async {
    final Database db = await connectedDatabase();
    var customerId;
    var Customer = await query('CUSTOMER',
        firstRow: true,
        where:
            "Name = '${billData['Customer_name']}' AND Surname = '${billData['Customer_surname']}' ");
    if (Customer != null) {
      customerId = await db.rawUpdate('''UPDATE CUSTOMER SET 
      Name = '${billData['Customer_name']}',Surname = '${billData['Customer_surname']}',
      Id_card = '${billData['Customer_id_card']}',Type_id = '${billData['Customer_type']}',
      Sex = '${billData['Customer_sex']}',Address = '${billData['Customer_address']}',
      District_id = '${billData['Customer_district_id']}',Amphur_id = '${billData['Customer_amphur_id']}',
      Province_id = '${billData['Customer_province_id']}',Zipcode = '${billData['Customer_zipcode']}',
      Birthday = '${billData['Customer_birthday']}',Phone = '${billData['Customer_phone']}',
      Image = '${billData['Image_customer']}',Image_id_card = '${billData['Image_id_card']}',
      Edit_user_id = '${billData['Edit_user_id']}',Timestamp = '${DateTime.now().toString().split('.')[0]}'
      WHERE ID = ${Customer['ID']}''');
    } else {
      customerId = await db.insert(
          'CUSTOMER',
          {
            'Name': billData['Customer_name'],
            'Surname': billData['Customer_surname'],
            'Id_card': billData['Customer_id_card'],
            'Type_id': billData['Customer_type'],
            'Sex': billData['Customer_sex'],
            'Address': billData['Customer_address'],
            'District_id': billData['Customer_district_id'],
            'Amphur_id': billData['Customer_amphur_id'],
            'Province_id': billData['Customer_province_id'],
            'Zipcode': billData['Customer_zipcode'],
            'Birthday': billData['Customer_birthday'],
            'Phone': billData['Customer_phone'],
            'Customer_ref_no1': 0,
            'Customer_ref_no2': 0,
            'Image': billData['Image_customer'],
            'Image_id_card': billData['Image_id_card'],
            'Edit_user_id': billData['Edit_user_id'],
            'Timestamp': DateTime.now().toString().split('.')[0],
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    var insertData = {
      'Trial_number': billData['DocNumber'],
      'Customer_id': customerId,
      'User_id': billData['User_id'],
      'Order_detail': billData['Order_detail'],
      'Image_receive': billData['Image_receive'],
      'Image_signature': billData['Image_signature'],
      'Status': 0, //ยังไม่ Sync
      'Timestamp': DateTime.now().toString().split('.')[0],
      'Date_create': DateTime.now().toString().split('.')[0],
      'Signature_date': DateTime.now().toString().split('.')[0],
      'Sale_work_car_id': billData['user']['Work_car_id'],
      'trail_location': billData['location'],
    };

    db.insert('TRAIL', insertData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> billRecord(Map<String, dynamic> billData) async {
    try {
      final Database db = await connectedDatabase();
      print('--------------> db --------> ${db}');
      var customerId;
      var Customer = await query('CUSTOMER',
          firstRow: true,
          where:
          "Name = '${billData['Customer_name']}' AND Surname = '${billData['Customer_surname']}' ");
      if (Customer != null) {
        // Update
        print('Update Customer');
        await db.rawUpdate('''UPDATE CUSTOMER SET 
      Name = '${billData['Customer_name']}',Surname = '${billData['Customer_surname']}',
      Id_card = '${billData['Customer_id_card']}',Type_id = '${billData['Customer_type']}',
      Sex = '${billData['Customer_sex']}',Address = '${billData['Customer_address']}',
      District_id = '${billData['Customer_district_id']}',Amphur_id = '${billData['Customer_amphur_id']}',
      Province_id = '${billData['Customer_province_id']}',Zipcode = '${billData['Customer_zipcode']}',
      Birthday = '${billData['Customer_birthday']}',Phone = '${billData['Customer_phone']}',
      Image = '${billData['Image_customer']}',Image_id_card = '${billData['Image_id_card']}',
      Edit_user_id = '${billData['Edit_user_id']}',Timestamp = '${DateTime.now().toString().split('.')[0]}'
      WHERE ID = ${Customer['ID']}''');
        customerId = Customer['ID'];
        print(customerId);
      } else {
        // insert
        print('Insert Customer');
        customerId = await db.insert(
            'CUSTOMER',
            {
              'Name': billData['Customer_name'],
              'Surname': billData['Customer_surname'],
              'Id_card': billData['Customer_id_card'],
              'Type_id': billData['Customer_type'],
              'Sex': billData['Customer_sex'],
              'Address': billData['Customer_address'],
              'District_id': billData['Customer_district_id'],
              'Amphur_id': billData['Customer_amphur_id'],
              'Province_id': billData['Customer_province_id'],
              'Zipcode': billData['Customer_zipcode'],
              'Birthday': billData['Customer_birthday'],
              'Phone': billData['Customer_phone'],
              'Customer_ref_no1': 0,
              'Customer_ref_no2': 0,
              'Image': billData['Image_customer'],
              'Image_id_card': billData['Image_id_card'],
              'Edit_user_id': billData['Edit_user_id'],
              'Timestamp': DateTime.now().toString().split('.')[0],
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      //print('CustomerId : $customerId');
      //print('UserId : ${billData['user']['ID']}');

      var insertData = {
        'Bill_number': billData['DocNumber'],
        'Customer_id': customerId,
        'User_id': billData['User_id'],
        'Pay_type': billData['Pay_type'],
        'Commission_sum': billData['Commission_sum'],
        'Date_send': billData['Date_send'],
        'Money_total': billData['Money_total'],
        'Sales_province_id': billData['user']['Sales_Province_id'],
        'Edit_user_id': billData['Edit_user_id'],
        'bill_location': billData['bill_location'].toString(),
        'Sale_work_car_id': billData['user']['Work_car_id'],
        'Order_detail': billData['Table_data'],
        'isSync': 0,
        'Timestamp': DateTime.now().toString().split('.')[0],
      };
      if (billData['Pay_type'] == 2 || billData['Pay_type'] == '2') {
        insertData['Money_due'] = billData['Money_due'];
        insertData['Money_earnest'] = billData['Money_earnest'];
        insertData['Credit_term_id'] = billData['Credit_term_id'];
        insertData['Date_due'] = billData['Date_due'];
      }
      if (billData['Images_sign'] != null || billData['Images_sign'] != '') {
        insertData['Image_signature'] = billData['Images_sign'];
        insertData['Signature_date'] = billData['Signature_date'];
      }
      if (billData['edit_status'] != 1) {
        if (billData['Images_sign'] == null || billData['Images_sign'] == '') {
          insertData['Status'] = 0;
        } else {
          if (billData['Pay_type'] == 2 || billData['Pay_type'] == '2') {
            insertData['Status'] = 2;
          } else {
            insertData['Status'] = 1;
          }
        }
      }

      // if ((billData['Customer_id_card'] == null || billData['Customer_id_card'] == '') && billData['Pay_type'] == 2) {
      //   insertData['Status'] = 0;
      // }

      if (billData['Bill_id'] == '') {
        insertData['Date_create'] = DateTime.now().toString().split('.')[0];
      } else {
        insertData['ID'] = billData['Bill_id'];
      }
      db.insert('BILL', insertData, conflictAlgorithm: ConflictAlgorithm.replace);
      return 'Successfully';
    }
    catch(e){
      return 'Failed';
    }
  }

  Future getUserData(int id) async {
    print("getUserData === ${id}");
    Database db = await connectedDatabase();
    List<Map> list = await db.rawQuery(
        'SELECT * FROM USER INNER JOIN PROVINCE ON PROVINCE.PROVINCE_ID = USER.Sales_Province_id WHERE USER.ID = "$id"');
    //var res = await db.query('User', where: "ID = '$id'");
    if (list.isNotEmpty)
      return list.first;
    else
      return null;
  }

  Future<List<Map<String, dynamic>>> getProductCanSell(int userId) async {
    return await rawQuery('''
    SELECT PRODUCT.ID,PRODUCT.Name,PRODUCT.Price_sell,PRODUCT.Price_commission,PRODUCT.Image,PRODUCT.Category_id
        FROM PRODUCT INNER JOIN USER_PRODUCT_CAN_SELL ON PRODUCT.ID = USER_PRODUCT_CAN_SELL.Product_id 
        WHERE PRODUCT.Category_id IN (1,2) AND PRODUCT.Status = 1 AND USER_PRODUCT_CAN_SELL.User_id = "$userId"
        AND USER_PRODUCT_CAN_SELL.Status = 1 ORDER BY Category_id ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getOfflineBill(int billId) async {
    return await rawQuery(
        '''SELECT BILL.*,CUSTOMER.*,PROVINCE.PROVINCE_ID,PROVINCE.PROVINCE_NAME,
    AMPHUR.AMPHUR_ID,AMPHUR.AMPHUR_NAME,DISTRICT.DISTRICT_ID,DISTRICT.DISTRICT_NAME,
    USER.Username,USER.Name as saleName,USER.Surname as saleSurname,CUSTOMER.ID as customerId,
    USER.Sales_Province_id as saleProvinceId
    FROM BILL INNER JOIN CUSTOMER ON BILL.Customer_id = CUSTOMER.ID 
    INNER JOIN PROVINCE ON CUSTOMER.Province_id = PROVINCE.PROVINCE_ID 
    INNER JOIN AMPHUR ON CUSTOMER.Amphur_id = AMPHUR.AMPHUR_ID 
    INNER JOIN DISTRICT ON CUSTOMER.District_id = DISTRICT.DISTRICT_ID 
    INNER JOIN USER ON BILL.User_id = USER.ID 
    WHERE BILL.ID = $billId
    ''');
  }

  Future<List<Map<String, dynamic>>> getBillById(int billId) async {
    return await rawQuery('''SELECT BILL.ID as Bill_id,
    CUSTOMER.Name as Customer_name,
    CUSTOMER.Surname as Customer_surname,
    BILL.Bill_number,
    BILL.User_id as Bill_user_id,
    BILL.Pay_type,
    BILL.Money_total,
    BILL.Money_earnest,
    BILL.Money_due,
    BILL.Date_send,
    BILL.Date_due,
    BILL.Date_pay,
    BILL.Commission_sum,
    BILL.Image_signature,
    BILL.Signature_date,
    BILL.Order_detail,
    BILL.Credit_term_id,
    BILL.bill_location
     FROM BILL INNER JOIN CUSTOMER ON BILL.Customer_id = CUSTOMER.ID WHERE BILL.ID = $billId''');
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql) async {
    Database db = await connectedDatabase();
    return await db.rawQuery(sql);
  }

  Future query(String table,
      {String select = '*',
      String where = '1',
      String join = '',
      bool firstRow = false,
      String group = '',
      String order = ''}) async {
    Database db = await connectedDatabase();
    var sql = 'SELECT $select FROM $table $join WHERE $where';
    List<Map> list = await db.rawQuery(sql);
    if (list.isNotEmpty) {
      if (firstRow) {
        return list.first;
      } else {
        return list;
      }
    }
    return null;
  }

  Future<User> getLogin(String username, String password) async {
    Database db = await connectedDatabase();
    var res = await db.query('USER',
        where:
            "Username = '$username' AND Password = '$password' AND Work_status = 1");
    if (res.length > 0) {
      return User.fromJson(res.first);
    }
    return null;
  }

//End User Provider

//SettingCar Provider
  Future<void> insertSettingCar(SettingCar settingCar) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    await db.insert(
      'SETTING_CAR',
      settingCar.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future getWorkCar(var work_car_id) async {
    final Database db = await connectedDatabase();
    List<Map> list = await db.rawQuery('''SELECT S.Plate_number,P.PROVINCE_NAME
        FROM SETTING_CAR AS S
        JOIN PROVINCE AS P ON P.PROVINCE_ID = S.Plate_province_id
        WHERE S.ID = "$work_car_id"
        ''');
    if (list.isNotEmpty)
      return list.first;
    else
      return null;
  }

  Future<List<SettingCar>> getSettingCar() async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    List<SettingCar> settingCar = List();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('SETTING_CAR');

    for (var map in maps) {
      SettingCar _data = SettingCar.fromJson(map);
      settingCar.add(_data);
    }

    return settingCar;
  }

//End SettingCar Provider

//UserMoneyShare Provider
  Future<void> insertUserMoneyShare(UserMoneyShare userMoneyShare) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    await db.insert(
      'USER_MONEY_SHARE',
      userMoneyShare.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserMoneyShare>> getUserMoneyShareById(int id) async {
    final Database db = await connectedDatabase();
    List<UserMoneyShare> data = List();
    final List<Map<String, dynamic>> maps = await db.query('USER_MONEY_SHARE',
        groupBy: 'To_user_id',
        where:
            "User_id = '$id' AND Status = '1' AND User_Level_id in ('2','3','12')",
        columns: ['User_Level_id', 'User_name', 'To_user_id']);
    for (var map in maps) {
      UserMoneyShare _data = UserMoneyShare.fromJson(map);
      data.add(_data);
    }
    return data;
  }

  Future<List<UserMoneyShare>> getUserMoneyShare() async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    List<UserMoneyShare> userMoneyShare = List();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('USER_MONEY_SHARE');

    for (var map in maps) {
      UserMoneyShare _data = UserMoneyShare.fromJson(map);
      userMoneyShare.add(_data);
    }

    return userMoneyShare;
  }

//End UserMoneyShare Provider

//Province Provider
  Future<void> insertProvince(Province province) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    await db.insert(
      'PROVINCE',
      province.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLand(List data, String table) async {
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    switch (table) {
      case 'CUSTOMER_TYPE':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Name': val['Name'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'PRODUCT':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Name': val['Name'],
                'Detail': val['Detail'],
                'Price_sell': val['Price_sell'],
                'Price_commission': val['Price_commission'],
                'Price_cost': val['Price_cost'],
                'Image': val['Image'],
                'Image_ref': val['Image_ref'],
                'Category_id': val['Category_id'],
                'Sequence': val['Sequence'],
                'Price_display': val['Price_display'],
                'Product_display': val['Product_display'],
                'Status': val['Status'],
                'Start_date': val['Start_date'],
                'End_date': val['End_date'],
                'Condition_1': val['Condition_1'],
                'Condition_2': val['Condition_2'],
                'Condition_3': val['Condition_3'],
                'Edit_user_id': val['Edit_user_id'],
                'Date_edit': val['Date_edit'],
                'Timpstamp': val['Timpstamp']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'CATEGORY':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Name': val['Name'],
                'Edit_user_id': val['Edit_user_id'],
                'Timestamp': val['Timestamp']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'STOCK_NOT_PRICE':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Name': val['Name'],
                'Price': val['Price'],
                'Qty': val['Qty'],
                'Exp_date': val['Exp_date'],
                'Status': val['Status'],
                'Remark': val['Remark'],
                'Edit_user_id': val['Edit_user_id'],
                'Timestamp': val['Timestamp']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'USER_PRODUCT_CAN_SELL':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'User_id': val['User_id'],
                'ID': val['ID'],
                'Product_id': val['Product_id'],
                'Status': val['Status'],
                'Edit_user_id': val['Edit_user_id'],
                'Timestamp': val['Timestamp']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'PROVINCE':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'PROVINCE_ID': val['PROVINCE_ID'],
                'PROVINCE_CODE': val['PROVINCE_CODE'],
                'PROVINCE_NAME': val['PROVINCE_NAME'],
                'GEO_ID': val['GEO_ID'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'DISTRICT':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'DISTRICT_ID': val['DISTRICT_ID'],
                'DISTRICT_CODE': val['DISTRICT_CODE'],
                'DISTRICT_NAME': val['DISTRICT_NAME'],
                'AMPHUR_ID': val['AMPHUR_ID'],
                'PROVINCE_ID': val['PROVINCE_ID'],
                'GEO_ID': val['GEO_ID'],
                'ZIP_CODE': val['ZIP_CODE']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'AMPHUR':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'AMPHUR_ID': val['AMPHUR_ID'],
                'AMPHUR_CODE': val['AMPHUR_CODE'],
                'AMPHUR_NAME': val['AMPHUR_NAME'],
                'GEO_ID': val['GEO_ID'],
                'PROVINCE_ID': val['PROVINCE_ID'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'GEOGRAPHY':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'GEO_ID': val['GEO_ID'],
                'GEO_NAME': val['GEO_NAME'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'CONDITION_OPEN_BILL_CREDIT':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Work_day_limit': val['Work_day_limit'],
                'Have_bill': val['Have_bill'],
                'Rate_start': val['Rate_start'],
                'Rate_end': val['Rate_end'],
                'Fixed_earnest': val['Fixed_earnest'],
                'Timestamp': val['Timestamp']
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
    }
    batch.commit(noResult: true);
  }

  Future<void> insertAmphur(Province province) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    await db.insert(
      'PROVINCE',
      province.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGEO(Province province) async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    await db.insert(
      'PROVINCE',
      province.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Province>> getProvince() async {
    // Get a reference to the database.
    final Database db = await connectedDatabase();

    List<Province> province = List();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('PROVINCE');

    for (var map in maps) {
      Province _data = Province.fromJson(map);
      province.add(_data);
    }

    return province;
  }

//End Province Provider

//Commission Provider
  Future insertCommission(int ID, var json) async {
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    // print(json);
    // var Data = jsonDecode(json);
    String jsonString;
    batch.insert('SaleCommission', {'ID': ID, 'DataSet': json},
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.commit(noResult: true);
  }

  Future getCommission(int ID) async {
    final Database db = await connectedDatabase();
    List<Map> list = await db.query('SaleCommission', where: 'ID = $ID');
    if (list.isNotEmpty)
      return list.first;
    else
      return null;
  }

//End Commission Provider

  Future<List<Map<String, dynamic>>> getUserById(var userId) async {
    return await rawQuery('SELECT * FROM USER WHERE ID = $userId');
  }

  Future<List<Map<String, dynamic>>> getUserAll() async {
    return await rawQuery('SELECT * FROM USER');
  }

  Future<int> insertContract(var contract) async {
    final Database db = await connectedDatabase();
    return db.insert(
        'CONTRACT',
        {
          "ID": contract['id'],
          "Contract_number": "${contract['contractNumber']}",
          "Receipt_id": null,
          "Bill_id": contract['billId'],
          "User_id": contract['userId'],
          "Image_signature": contract['imageSignature'],
          "Signature_date": contract['signatureDate'],
          "Image_signature_witness_1": contract['imageSignatureWitness1'],
          "Witness_name_1": contract['witnessName1'],
          "Image_signature_witness_2": contract['imageSignatureWitness2'],
          "Witness_name_2": contract['witnessName2'],
          "Other_name_1": contract['otherName1'],
          "Other_relationship_1": contract['otherRela1'],
          "Other_phone_1": contract['otherPhone1'],
          "Other_name_2": contract['otherName2'],
          "Other_relationship_2": contract['otherRela2'],
          "Other_phone_2": contract['otherPhone2'],
          "Book_number": "${contract['bookNumber']}",
          "Status": 1,
          "Edit_user_id": contract['editUserId'],
          "Timestamp": "${DateTime.now().toString().split('.')[0]}"
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Null> insertReceipt(var rec) async {
    final Database db = await connectedDatabase();
    try {
      print("rec['Image_receive'] ------> ${rec['Image_receive']}");

      await db.insert(
          'RECEIPT',
          {
            'ID': rec['ID'],
            'Receipt_number': rec['Receipt_number'],
            'Bill_id': rec['Bill_id'],
            'User_id': rec['User_id'],
            'Image_signature': rec['Image_signature'],
            'Signature_date': rec['Signature_date'],
            'Image_receive': rec['Image_receive'],
            // 'Image_receive_name': rec['img_name'],
            'Status': 1,
            'Edit_user_id': rec['Edit_user_id'],
            'receipt_location': rec['receipt_location'],
            'isSync': 0,
            'Timestamp': DateTime.now().toString().split('.')[0],
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      await db.rawUpdate(
          'UPDATE BILL SET Status = 4,isSync = 0 WHERE ID = ${rec['Bill_id']}');
      print('success');
    } catch (e) {
      print('e -------> ${e}');
    }
  }

  Future getContract(int id) async {
    return rawQuery('''SELECT CONTRACT.*,BILL.Bill_number FROM CONTRACT 
    INNER JOIN BILL ON CONTRACT.Bill_id = BILL.ID
    WHERE CONTRACT.User_id = $id AND CONTRACT.Receipt_id IS NULL''');
  }

  Future getReceipt() async {
    return rawQuery('''
        SELECT RECEIPT.Receipt_number,RECEIPT.Image_signature as Receipt_image_signature
        ,RECEIPT.Signature_date as Receipt_signature_date,RECEIPT.Image_receive
        ,RECEIPT.Status as Receipt_status,RECEIPT.Edit_user_id as Receipt_edit_user_id
        ,RECEIPT.Timestamp as Receipt_timestamp,RECEIPT.ID as ReceiptId,BILL.Bill_number,RECEIPT.receipt_location
        ,RECEIPT.isSync,RECEIPT.User_id as UserId,CONTRACT.* FROM RECEIPT INNER JOIN BILL ON RECEIPT.Bill_id = BILL.ID 
        LEFT JOIN CONTRACT ON CONTRACT.Bill_id = BILL.ID
        ''');
  }

  Future getAllTrail() async {
    return rawQuery('''
    SELECT TRAIL.ID as Trail_id,TRAIL.Trial_number,TRAIL.Customer_id,TRAIL.User_id,TRAIL.Order_detail,TRAIL.Timestamp as Trail_timestamp,TRAIL.Status,
    TRAIL.Image_signature,TRAIL.Image_receive,TRAIL.trail_location,
    CUSTOMER.* FROM TRAIL LEFT JOIN CUSTOMER ON CUSTOMER.ID = TRAIL.Customer_id 
    ''');
  }

  Future<Null> updateBill(var billData, var offlineId) async {
    final Database db = await connectedDatabase();
    await db.rawUpdate(
        '''UPDATE BILL SET Date_send = "${billData['Date_send']}",Pay_type = "${billData['Pay_type']}",
        Commission_sum = "${billData['Commission_sum']}",Money_total = "${billData['Money_total']}",Edit_user_id = "${billData['Edit_user_id']}",
    bill_location = "${billData['bill_location']}",Order_detail = '${billData['Order_detail']}',
    Timestamp = "${billData['Timestamp']}",Money_due = "${billData['Money_due']}",Money_earnest = "${billData['Money_earnest']}",
    Credit_term_id = "${billData['Credit_term_id']}",Date_due = "${billData['Date_due']}",Image_signature = "${billData['Image_signature']}",
    Status = "${billData['Status']}",Signature_date = "${billData['Signature_date']}",Remark = "${billData['Remark']}",isSync = 2 WHERE ID = $offlineId''');
  }

  Future<Null> updateReceipt(var receiptData, var offlineId) async {
    final Database db = await connectedDatabase();
    await db.rawUpdate('''
    UPDATE RECEIPT SET isSync = 2,Image_signature = "${receiptData['Image_signature']}",Signature_date = "${receiptData['Signature_date']}",
    Status = "${receiptData['Status']}",Edit_user_id = "${receiptData['Edit_user_id']}" , Timestamp = "${receiptData['Timestamp']}"
    WHERE ID = $offlineId
    ''');
  }

  Future<List<Map<String, dynamic>>> getTrail(int userId,
      {String selectStart = '',
      String selectEnd = '',
      String where = ''}) async {
    DateTime n = DateTime.now();
    String startDate = DateTime(n.year, n.month).toString().split(' ')[0];
    String endDate = DateTime(n.year, n.month, n.day).toString().split(' ')[0];

    if (selectStart != '') {
      startDate = selectStart;
      endDate = selectEnd;
    }
    if (where != '') {
      where += ' AND';
    }

    var res = await rawQuery('''
    SELECT TRAIL.ID as trail_id,TRAIL.Trial_number,TRAIL.Customer_id,TRAIL.User_id,TRAIL.Order_detail,TRAIL.Date_create,TRAIL.Status,
    CUSTOMER.*,CUSTOMER_TYPE.Name as Customer_type,PROVINCE.PROVINCE_NAME,DISTRICT.DISTRICT_NAME,AMPHUR.AMPHUR_NAME
    FROM TRAIL
    LEFT JOIN CUSTOMER ON CUSTOMER.ID = TRAIL.Customer_id 
    LEFT JOIN PROVINCE ON PROVINCE.PROVINCE_ID = CUSTOMER.Province_id 
    LEFT JOIN AMPHUR ON AMPHUR.AMPHUR_ID = CUSTOMER.Amphur_id 
    LEFT JOIN DISTRICT ON DISTRICT.DISTRICT_ID = CUSTOMER.District_id 
    LEFT JOIN CUSTOMER_TYPE ON CUSTOMER_TYPE.ID = CUSTOMER.Type_id
    WHERE $where TRAIL.User_id = $userId AND TRAIL.Date_create BETWEEN '${startDate} 00:00:00' AND '${endDate} 23:59:59' 
    ORDER BY TRAIL.Timestamp DESC
    ''');
    return res;
  }

  // Future<List<Map<String, dynamic>>> getAllBill() async {
  //   return await rawQuery('SELECT * FROM BILL WHERE');
  // }

  Future<List<Map<String, dynamic>>> getBill(var userId,
      {String selectStart = '',
      String selectEnd = '',
      String where = ''}) async {
    DateTime n = DateTime.now();
    String startDate = DateTime(n.year, n.month).toString().split(' ')[0];
    String endDate = DateTime(n.year, n.month, n.day).toString().split(' ')[0];
    if (selectStart != '') {
      startDate = selectStart;
      endDate = selectEnd;
    }
    if (where != '') {
      where += ' AND';
    }

    String query = ''' SELECT BILL.*,
                                   RECEIPT.Receipt_number,
                                   RECEIPT.Status as Receipt_status,
                                   RECEIPT.ID as Receipt_id,
                                   CUSTOMER.Name as Customer_name,
                                   CUSTOMER.Surname as Customer_surname,
                                   RECEIPT.isSync as ReceiptSync,
                                   CUSTOMER.ID as CustomerID,
                                   USER.Name as Sale_name FROM BILL
    LEFT JOIN CUSTOMER ON CUSTOMER.ID = BILL.Customer_id LEFT JOIN RECEIPT ON BILL.ID = RECEIPT.Bill_id LEFT JOIN USER ON BILL.User_id = USER.ID
    WHERE $where (BILL.User_id = '$userId' OR BILL.Consign_user_id = '$userId') AND BILL.Date_create BETWEEN '$startDate 00:00:00' AND '$endDate 23:59:59' 
    ORDER BY BILL.Timestamp DESC
    ''';

    //print(query);

    var res = await rawQuery(query);

    return res;
  }

  Future<Null> deleteBill(int id) async {
    final Database db = await connectedDatabase();
    Batch batch = db.batch();
    batch.delete('CONTRACT', where: 'Bill_id = $id');
    batch.delete('RECEIPT', where: 'Bill_id = $id');
    batch.delete('BILL', where: 'ID = $id');
    batch.commit(noResult: true);
  }

  Future<Null> insertUserAll(List data, String table) async {
    Database db = await connectedDatabase();
    Batch batch = db.batch();
    switch (table) {
      case 'USER_MONEY_SHARE':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'User_id': val['User_id'],
                'ID': val['ID'],
                'Money_share_type_id': val['Money_share_type_id'],
                'Money_share_type_name': val['Money_share_type_name'],
                'Money': val['Money'],
                'To_user_id': val['To_user_id'],
                'User_name': val['User_name'],
                'User_Level_id': val['User_Level_id'],
                'User_Level_name': val['User_Level_name'],
                'Status': val['Status'],
                'Edit_user_id': val['Edit_user_id'],
                'Timestamp': val['Timestamp'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'SETTING_CAR':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Plate_number': val['Plate_number'],
                'Plate_province_id': val['Plate_province_id'],
                'Price': val['Price'],
                'Price_remain': val['Price_remain'],
                'Price_term': val['Price_term'],
                'Note': val['Note'],
                'Status': val['Status'],
                'Image_ref': val['Image_ref'],
                'Edit_user_id': val['Edit_user_id'],
                'Timestamp': val['Timestamp'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
      case 'USER':
        data.forEach((val) {
          batch.insert(
              table,
              {
                'ID': val['ID'],
                'Username': val['Username'],
                'Password': val['Password'],
                'Level_id': val['Level_id'],
                'Name': val['Name'],
                'Surname': val['Surname'],
                'Id_card': val['Id_card'],
                'Setting_commission': val['Setting_commission'],
                'Setting_recommend': val['Setting_recommend'],
                'Work_date_start': val['Work_date_start'],
                'Work_team_user_id': val['Work_team_user_id'],
                'Work_manager_user_id': val['Work_manager_user_id'],
                'Work_car_number': val['Work_car_number'],
                'Work_status': val['Work_status'],
                'Work_car_id': val['Work_car_id'],
                'Goal': val['Goal'],
                'Edit_user_id': val['Edit_user_id'],
                'Bank_id': val['Bank_id'],
                'Bank_account': val['Bank_account'],
                'Address': val['Address'],
                'District_id': val['District_id'],
                'Amphur_id': val['Amphur_id'],
                'Province_id': val['Province_id'],
                'Sex': val['Sex'],
                'Birthday': val['Birthday'],
                'User_id_recommend': val['User_id_recommend'],
                'Image': val['Image'],
                'Image_id_card': val['Image_id_card'],
                'Before_after_type': val['Before_after_type'],
                'Setting_commission_percent': val['Setting_commission_percent'],
                'Sales_Province_id': val['Sales_Province_id'],
                'Timestamp': val['Timestamp'],
                'Sale_vip_team_id': val['Sale_vip_team_id'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        break;
    }
    batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getTrailById(int trailId) async {
    return await rawQuery('''SELECT 
    CUSTOMER.*,
    TRAIL.ID as Trail_id,
    TRAIL.*
    FROM TRAIL 
    INNER JOIN CUSTOMER ON TRAIL.Customer_id = CUSTOMER.ID 
    WHERE TRAIL.ID = $trailId''');
  }

  Future getUserDataById(id) async {
    return rawQuery('''
    SELECT USER.*,PROVINCE.* FROM USER 
    JOIN PROVINCE ON PROVINCE.PROVINCE_ID = USER.Sales_Province_id
    WHERE USER.ID = $id
    ''');
  }

  Future getHeader(id) async {
    return rawQuery('''
    SELECT * FROM USER_MONEY_SHARE WHERE User_id = $id AND User_Level_id = 2 AND Status = 1
    ''');
  }

  Future getSubManager(id) async {
    return rawQuery('''
    SELECT * FROM USER_MONEY_SHARE 
    WHERE User_id = $id AND User_Level_id = 12 AND Status = 1
    GROUP BY To_user_id
    ''');
  }

  Future getManager(id) async {
    return rawQuery('''
    SELECT * FROM USER_MONEY_SHARE 
    WHERE User_id = $id AND User_Level_id = 3 AND Status = 1
    GROUP BY To_user_id
    ''');
  }

  Future getJson(String table, String key) async {
    final Database db = await connectedDatabase();
    List<Map> list = await db.rawQuery(
        'SELECT * FROM JSON_TABLE WHERE DATA_TABLE = "$table" AND JSON_KEY = "$key"');
    if (list.isNotEmpty)
      return list.first;
    else
      return null;
  }

  Future headCarCount(id) async {
    return rawQuery('''
    SELECT USER.Work_car_id FROM USER_MONEY_SHARE 
    LEFT JOIN USER ON USER_MONEY_SHARE.User_id = USER.ID
    WHERE USER_MONEY_SHARE.To_user_id = $id
    AND USER_MONEY_SHARE.Status = 1 
    AND USER.Work_status = 1 
    GROUP BY USER.Work_car_id
    ''');
  }

  Future headTeamGoal(id) async {
    return rawQuery('''
    SELECT SUM(USER.Goal) as Goal FROM USER_MONEY_SHARE 
    LEFT JOIN USER ON USER_MONEY_SHARE.User_id = USER.ID
    WHERE USER_MONEY_SHARE.To_user_id = $id 
    AND USER_MONEY_SHARE.Status = 1 
    GROUP BY USER_MONEY_SHARE.To_user_id
    ''');
  }

  Future getTeamForManager(id) async {
    return rawQuery('''
    SELECT USER.ID FROM USER_MONEY_SHARE 
    LEFT JOIN USER ON USER_MONEY_SHARE.User_id = USER.ID
    WHERE USER_MONEY_SHARE.To_user_id = $id
    AND USER.Level_id IN (2,12)
    ''');
  }

  Future getSaleForManager(id) async {
    return rawQuery('''
    SELECT COUNT(USER.ID) as Count FROM USER_MONEY_SHARE 
    LEFT JOIN USER ON USER_MONEY_SHARE.User_id = USER.ID
    WHERE USER_MONEY_SHARE.To_user_id = $id
    AND USER_MONEY_SHARE.Status = 1
    ''');
  }

  Future getHeadDetail(id) async {
    var data = await getUserData(id);
    var userData = Map.of(data);
    var teamCount = await rawQuery(
        'SELECT COUNT(ID) as count FROM USER WHERE Work_car_id = ${userData['Work_car_id']} AND ID <> $id');
    var carCount = await headCarCount(id);
    var carPlateNumber = await rawQuery(
        'SELECT SETTING_CAR.Plate_number  FROM SETTING_CAR WHERE ID = ${userData['Work_car_id']} ');
    userData['car_count'] = carCount.length ?? 0;
    userData['team_count'] = teamCount[0]['count'] ?? 0;
    userData['car_platenumber'] = carPlateNumber[0]['Plate_number'] ?? '-';
    return userData;
  }

  Future managerTeamGoal(id, carId) async {
    return rawQuery('''
    SELECT SUM(USER.Goal) as Goal FROM USER_MONEY_SHARE
    LEFT JOIN USER ON USER_MONEY_SHARE.User_id = USER.ID
    WHERE USER_MONEY_SHARE.To_user_id = $id
    AND USER_MONEY_SHARE.Status = 1
    AND USER.Work_car_id = $carId
    GROUP BY USER_MONEY_SHARE.To_user_id
    ''');
  }

  Future<Map<String, dynamic>> getDetailCar(carId) async {
    var res = await rawQuery('''
    SELECT 
    (SETTING_CAR.Plate_number|| ' ' ||PROVINCE.PROVINCE_NAME) as car_name,
    (
      SELECT Name|| ' ' ||Surname FROM USER WHERE Work_car_id = SETTING_CAR.ID
      AND Level_id IN (2,3,12) AND Work_status = 1 LIMIT 1
    ) as team_name
    FROM SETTING_CAR 
    INNER JOIN PROVINCE ON PROVINCE.PROVINCE_ID = SETTING_CAR.Plate_province_id 
    WHERE SETTING_CAR.ID = $carId
    ''');
    return res[0];
  }

  Future<Null> updateUserData(int id, Map<String, dynamic> data) async {
    final Database db = await connectedDatabase();
    await db.rawQuery('''
    UPDATE USER SET Password = '${data['Password']}',Name = '${data['Name']}', 
    Surname = '${data['Surname']}',Id_card = '${data['Id_card']}',
    Sex = '${data['Sex']}',Birthday = '${data['Birthday']}',
    Province_id = '${data['Province_id']}',Amphur_id = '${data['Amphur_id']}',
    District_id = '${data['District_id']}',Address = '${data['Address']}',
    Bank_account = '${data['Bank_account']}',Bank_id = '${data['Bank_id']}',
    Edit_user_id = '${data['Edit_user_id']}',Image = '${data['Image']}'
    WHERE ID = $id
    ''');
  }

  Future<Null> insertOrUpdateBillFromOnline(Map<String, dynamic> data) async {
    final Database db = await connectedDatabase();
    print('insertOrUpdateBillFromOnline');
    print('${data}');
    var Bill = await query('BILL',
        firstRow: true, where: "Bill_number = '${data['Bill_number']}'  ");
    if (Bill == null) {
      var customerId;
      var billId;
      var receiptId;
      print('Bill_number => ${data['Bill_number']} No offline ');
      var Customer = await query('CUSTOMER',
          firstRow: true,
          where:
              "Name = '${data['Customer_name']}' AND Surname = '${data['Customer_surname']}' ");
      if (Customer != null) {
        // Update
        print('Update Customer');
        await db.rawUpdate('''UPDATE CUSTOMER SET
        Name = '${data['Customer_name']}',Surname = '${data['Customer_surname']}',
        Id_card = '${data['Customer_id_card']}',Type_id = '${data['Customer_type']}',
        Sex = '${data['Customer_sex']}',Address = '${data['Customer_address']}',
        District_id = '${data['Customer_district_id']}',Amphur_id = '${data['Customer_amphur_id']}',
        Province_id = '${data['Customer_province_id']}',Zipcode = '${data['Customer_zipcode']}',
        Birthday = '${data['Customer_birthday']}',Phone = '${data['Customer_phone']}',
        Image = '${data['Image_customer']}',Image_id_card = '${data['Image_id_card']}',
        Edit_user_id = '${data['Edit_user_id']}',Timestamp = '${DateTime.now().toString().split('.')[0]}'
        WHERE ID = ${Customer['ID']}''');
        customerId = Customer['ID'];
        print(customerId);
      } else {
        // insert
        print('Insert Customer');
        customerId = await db.insert(
            'CUSTOMER',
            {
              'Name': data['Customer_name'],
              'Surname': data['Customer_surname'],
              'Id_card': data['Customer_id_card'],
              'Type_id': data['Customer_type'],
              'Sex': data['Customer_sex'],
              'Address': data['Customer_address'],
              'District_id': data['Customer_district_id'],
              'Amphur_id': data['Customer_amphur_id'],
              'Province_id': data['Customer_province_id'],
              'Zipcode': data['Customer_zipcode'],
              'Birthday': data['Customer_birthday'],
              'Phone': data['Customer_phone'],
              'Customer_ref_no1': data['Customer_ref_no1'],
              'Customer_ref_no2': data['Customer_ref_no2'],
              'Image': data['Image_customer'],
              'Image_id_card': data['Image_id_card'],
              'Edit_user_id': data['Edit_user_id'],
              'Timestamp': DateTime.now().toString().split('.')[0],
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print('CustomerId : $customerId');
      //print('UserId : ${billData['user']['ID']}');

      var insertData = {
        'Bill_number': data['Bill_number'],
        'Customer_id': customerId,
        'User_id': data['User_id'],
        'Pay_type': data['Pay_type'],
        'Commission_sum': data['Commission_sum'],
        'Date_send': data['Date_send'],
        'Money_total': data['Money_total'],
        'Sales_province_id': data['Sales_province_id'],
        'Edit_user_id': data['Edit_user_id'],
        'bill_location': data['bill_location'].toString(),
        'Sale_work_car_id': data['Sale_work_car_id'],
        'Order_detail': data['Order_detail'],
        'Image_signature': data['Image_signature'],
        'Signature_date': data['Signature_date'],
        'Date_create': data['Date_create'],
        'Status': data['Status'],
        'isSync': 2,
        'Timestamp': DateTime.now().toString().split('.')[0],
      };
      if (data['Pay_type'] == 2 || data['Pay_type'] == '2') {
        insertData['Money_due'] = data['Money_due'];
        insertData['Money_earnest'] = data['Money_earnest'];
        insertData['Credit_term_id'] = data['Credit_term_id'];
        insertData['Date_due'] = data['Date_due'];
      }
      billId = await db.insert('BILL', insertData,
          conflictAlgorithm: ConflictAlgorithm.replace);

      if (data['Receipt_number'] != null && data['Receipt_number'] != 'null') {
        var insertReceipt = {
          'ID': data['ID'],
          'Receipt_number': data['Receipt_number'],
          'Bill_id': billId,
          'User_id': data['User_id'],
          'Image_signature': data['Receipt_Image_signature'],
          'Signature_date': data['Receipt_Signature_date'],
          'Image_receive': data['Receipt_Image_receive'],
          'Status': data['Receipt_Status'],
          'Edit_user_id': data['Receipt_Edit_user_id'],
          'receipt_location': data['Receipt_receipt_location'],
          'isSync': 2,
          'Timestamp': DateTime.now().toString().split('.')[0],
        };
        receiptId = await db.insert('RECEIPT', insertReceipt,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      if (data['Contract_number'] != null &&
          data['Contract_number'] != 'null') {
        db.insert(
            'CONTRACT',
            {
              "Contract_number": "${data['Contract_number']}",
              "Receipt_id": null,
              "Bill_id": billId,
              "User_id": data['User_id'],
              "Image_signature": data['Contract_Image_signature'],
              "Signature_date": data['Contract_Signature_date'],
              "Image_signature_witness_1":
                  data['Contract_Image_signature_witness_1'],
              "Witness_name_1": data['Contract_Witness_name_1'],
              "Image_signature_witness_2":
                  data['Contract_Image_signature_witness_2'],
              "Witness_name_2": data['Contract_Witness_name_2'],
              "Other_name_1": data['Contract_Other_name_1'],
              "Other_relationship_1": data['Contract_Other_relationship_1'],
              "Other_phone_1": data['Contract_Other_phone_1'],
              "Other_name_2": data['Contract_Other_name_2'],
              "Other_relationship_2": data['Contract_Other_relationship_2'],
              "Other_phone_2": data['Contract_Other_phone_2'],
              "Book_number": "${data['Contract_Book_number']}",
              "Status": data['Contract_Status'],
              "Edit_user_id": data['Contract_Edit_user_id'],
              "Timestamp": "${DateTime.now().toString().split('.')[0]}"
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } else {
      //ดึงมาจากServerแล้ว 1 ครั้ง
      var customerId;
      print('Bill_number => ${data['Bill_number']} Have Offline ');

      var Customer = await query('CUSTOMER',
          firstRow: true,
          where:
              "Name = '${data['Customer_name']}' AND Surname = '${data['Customer_surname']}' ");
      if (Customer != null) {
        // Update
        print('Update Customer');
        await db.rawUpdate('''UPDATE CUSTOMER SET
        Name = '${data['Customer_name']}',Surname = '${data['Customer_surname']}',
        Id_card = '${data['Customer_id_card']}',Type_id = '${data['Customer_type']}',
        Sex = '${data['Customer_sex']}',Address = '${data['Customer_address']}',
        District_id = '${data['Customer_district_id']}',Amphur_id = '${data['Customer_amphur_id']}',
        Province_id = '${data['Customer_province_id']}',Zipcode = '${data['Customer_zipcode']}',
        Birthday = '${data['Customer_birthday']}',Phone = '${data['Customer_phone']}',
        Image = '${data['Image_customer']}',Image_id_card = '${data['Image_id_card']}',
        Edit_user_id = '${data['Edit_user_id']}',Timestamp = '${DateTime.now().toString().split('.')[0]}'
        WHERE ID = ${Customer['ID']}''');
        customerId = Customer['ID'];
      }

      await db.rawUpdate(
          '''UPDATE BILL SET Date_send = "${data['Date_send']}",Pay_type = "${data['Pay_type']}",
        Commission_sum = "${data['Commission_sum']}",Money_total = "${data['Money_total']}",Edit_user_id = "${data['Edit_user_id']}",
    bill_location = "${data['bill_location']}",Order_detail = '${data['Order_detail']}',
    Timestamp = "${data['Timestamp']}",Money_due = "${data['Money_due']}",Money_earnest = "${data['Money_earnest']}",
    Credit_term_id = "${data['Credit_term_id']}",Date_due = "${data['Date_due']}",Image_signature = "${data['Image_signature']}",
    Status = "${data['Status']}",Signature_date = "${data['Signature_date']}",Remark = "${data['Remark']}",isSync = 2 WHERE Bill_number = "${data['Bill_number']}"''');
    }
    // var customerId;
  }

  Future<Null> insertOrUpdateTrailFromOnline(Map<String, dynamic> data) async {
    final Database db = await connectedDatabase();
    print('insertOrUpdateTrailFromOnline');
    print('${data}');
    var customerId;
    var Trail = await query('TRAIL',
        firstRow: true, where: "Trial_number = '${data['Trial_number']}'  ");
    if (Trail == null) {
      print('Trial_number => ${data['Trial_number']} No offline ');
      var Customer = await query('CUSTOMER',
          firstRow: true,
          where:
              "Name = '${data['Customer_name']}' AND Surname = '${data['Customer_surname']}' ");
      if (Customer != null) {
        customerId = await db.rawUpdate('''UPDATE CUSTOMER SET 
      Name = '${data['Customer_name']}',Surname = '${data['Customer_surname']}',
      Id_card = '${data['Customer_id_card']}',Type_id = '${data['Customer_type']}',
      Sex = '${data['Customer_sex']}',Address = '${data['Customer_address']}',
      District_id = '${data['Customer_district_id']}',Amphur_id = '${data['Customer_amphur_id']}',
      Province_id = '${data['Customer_province_id']}',Zipcode = '${data['Customer_zipcode']}',
      Birthday = '${data['Customer_birthday']}',Phone = '${data['Customer_phone']}',
      Image = '${data['Image_customer']}',Image_id_card = '${data['Image_id_card']}',
      Edit_user_id = '${data['Edit_user_id']}',Timestamp = '${DateTime.now().toString().split('.')[0]}'
      WHERE ID = ${Customer['ID']}''');
      } else {
        customerId = await db.insert(
            'CUSTOMER',
            {
              'Name': data['Customer_name'],
              'Surname': data['Customer_surname'],
              'Id_card': data['Customer_id_card'],
              'Type_id': data['Customer_type'],
              'Sex': data['Customer_sex'],
              'Address': data['Customer_address'],
              'District_id': data['Customer_district_id'],
              'Amphur_id': data['Customer_amphur_id'],
              'Province_id': data['Customer_province_id'],
              'Zipcode': data['Customer_zipcode'],
              'Birthday': data['Customer_birthday'],
              'Phone': data['Customer_phone'],
              'Customer_ref_no1': data['Customer_ref_no1'],
              'Customer_ref_no2': data['Customer_ref_no2'],
              'Image': data['Image_customer'],
              'Image_id_card': data['Image_id_card'],
              'Edit_user_id': data['Edit_user_id'],
              'Timestamp': DateTime.now().toString().split('.')[0],
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      var insertData = {
        'Trial_number': data['Trial_number'],
        'Customer_id': customerId,
        'User_id': data['User_id'],
        'Order_detail': data['Order_detail'],
        'Image_receive': data['Image_receive'],
        'Image_signature': data['Image_signature'],
        'Status': data['Status'],
        'Timestamp': data['Timestamp'],
        'Date_create': data['Date_create'],
        'Sale_work_car_id': data['Sale_work_car_id'],
        'trail_location': data['trail_location'],
        'Signature_date': data['Signature_date'],
        'Edit_user_id': data['Edit_user_id'],
      };

      db.insert('TRAIL', insertData,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      print('Trial_number => ${data['Trial_number']} Have offline ');
    }
  }
}

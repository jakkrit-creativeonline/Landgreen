// ignore: camel_case_types
class sqltext {
  final sqlInitUser = '''CREATE TABLE USER 
          (ID INTEGER PRIMARY KEY, 
          Username TEXT DEFAULT NULL,
          Password TEXT DEFAULT NULL,
          Level_id INTEGER DEFAULT NULL,
          Name TEXT,
          Surname TEXT,
          Id_card TEXT DEFAULT NULL,
          Setting_commission INTEGER DEFAULT 0,
          Setting_recommend INTEGER DEFAULT 0,
          Work_date_start NUMERIC DEFAULT NULL,
          Work_team_user_id INTEGER DEFAULT NULL,
          Work_manager_user_id INTEGER DEFAULT NULL,
          Work_car_number TEXT,
          Work_status INTEGER DEFAULT NULL,
          Work_car_id INTEGER DEFAULT NULL,
          Goal INTEGER DEFAULT 0,
          Edit_user_id INTEGER DEFAULT NULL,
          Bank_id INTEGER DEFAULT NULL,
          Bank_account TEXT DEFAULT NULL,
          Address TEXT,
          District_id INTEGER DEFAULT NULL,
          Amphur_id INTEGER DEFAULT NULL,
          Province_id INTEGER DEFAULT NULL,
          Sex INTEGER DEFAULT NULL,
          Birthday NUMERIC DEFAULT NULL,
          User_id_recommend INTEGER DEFAULT NULL,
          Image TEXT,
          Image_id_card TEXT,
          Before_after_type INTEGER DEFAULT 0,
          Setting_commission_percent INTEGER DEFAULT NULL,
          Sales_Province_id INTEGER DEFAULT NULL,
          Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          Sale_vip_team_id INTEGER DEFAULT 0
           )''';
  final sqlInitSettingCar = '''CREATE TABLE `SETTING_CAR` (
  `ID` INTEGER PRIMARY KEY,
  `Plate_number` varchar(10) DEFAULT NULL,
  `Plate_province_id` int(11) DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `Price_remain` float DEFAULT NULL,
  `Price_term` tinyint(4) DEFAULT NULL,
  `Note` tinytext DEFAULT '',
  `Status` tinyint(1) DEFAULT 1,
  `Image_ref` text DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitUserMoneyShare = '''CREATE TABLE `USER_MONEY_SHARE` (
  `User_id` int(11) NOT NULL,
  `ID` INTEGER PRIMARY KEY,
  `Money_share_type_id` int(11) NOT NULL,
  `Money_share_type_name` text DEFAULT NULL,
  `Money` float NOT NULL,
  `To_user_id` int(11) NOT NULL,
  `User_name` text DEFAULT NULL,
  `User_Level_id` int(11) DEFAULT NULL,
  `User_Level_name` text DEFAULT NULL,
  `Status` tinyint(4) DEFAULT 1,
  `Edit_user_id` int(11) NOT NULL,
  `Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitProvice = '''CREATE TABLE `PROVINCE` (
  `PROVINCE_ID` INTEGER PRIMARY KEY,
  `PROVINCE_CODE` varchar(2) ,
  `PROVINCE_NAME` varchar(150),
  `GEO_ID` int(5) NOT NULL DEFAULT 0)''';
  final sqlInitSaleCommission = '''CREATE TABLE `SaleCommission` (
  `ID` INTEGER PRIMARY KEY,
  `DataSet` TEXT
  )
  ''';
  final sqlInitDistrict = '''CREATE TABLE `DISTRICT` (
  `DISTRICT_ID` INTEGER PRIMARY KEY,
  `DISTRICT_CODE` varchar(6) NOT NULL,
  `DISTRICT_NAME` varchar(150) NOT NULL,
  `AMPHUR_ID` int(5) NOT NULL DEFAULT 0,
  `PROVINCE_ID` int(5) NOT NULL DEFAULT 0,
  `GEO_ID` int(5) NOT NULL DEFAULT 0,
  `ZIP_CODE` int(11) DEFAULT NULL
)''';
  final sqlInitAmphur = '''
  CREATE TABLE `AMPHUR` (
  `AMPHUR_ID` INTEGER PRIMARY KEY,
  `AMPHUR_CODE` varchar(4) NOT NULL,
  `AMPHUR_NAME` varchar(150) NOT NULL,
  `GEO_ID` int(5) NOT NULL DEFAULT 0,
  `PROVINCE_ID` int(5) NOT NULL DEFAULT 0
)''';
  final sqlInitGEO = '''
  CREATE TABLE `GEOGRAPHY` (
  `GEO_ID` INTEGER PRIMARY KEY,
  `GEO_NAME` varchar(255) NOT NULL
)''';
  final sqlInitBILL = '''
  CREATE TABLE `BILL` (
  `ID` INTEGER PRIMARY KEY,
  `Bill_number` tinytext DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Customer_id` int(11) DEFAULT NULL,
  `Pay_type` tinyint(4) DEFAULT NULL,
  `Money_total` float DEFAULT NULL,
  `Money_earnest` float DEFAULT 0,
  `Money_due` float DEFAULT 0,
  `Date_send` date DEFAULT NULL,
  `Date_due` date DEFAULT NULL,
  `Date_pay` date DEFAULT NULL,
  `Status` tinyint(4) DEFAULT NULL,
  `Commission_pay` float DEFAULT 0,
  `Commission_sum` float DEFAULT NULL,
  `Commission_paydate` datetime DEFAULT NULL,
  `Image_signature` longtext DEFAULT NULL,
  `Signature_date` datetime DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` TEXT DEFAULT CURRENT_TIMESTAMP,
  `Order_detail` longtext DEFAULT NULL,
  `Credit_term_id` int(11) DEFAULT NULL,
  `Sales_province_id` int(11) DEFAULT NULL,
  `Date_create` TEXT DEFAULT CURRENT_TIMESTAMP,
  `Consign_user_id` int(11) DEFAULT NULL,
  `Remark` text DEFAULT NULL,
  `idheadsale` int(11) DEFAULT NULL,
  `idcredit` int(11) DEFAULT NULL,
  `bill_location` text DEFAULT NULL,
  `Sale_work_car_id` int(11) DEFAULT NULL,
  `Status_app_puiya` tinyint(4) DEFAULT 0,
  `Open_invoice` tinyint(4) DEFAULT 0,
  isSync int DEFAULT 0
)
''';
  final sqlInitRECEIPT = '''
  CREATE TABLE `RECEIPT` (
  `ID` INTEGER PRIMARY KEY,
  `Receipt_number` tinytext DEFAULT NULL,
  `Bill_id` int(11) DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Image_signature` longtext DEFAULT NULL,
  `Signature_date` datetime DEFAULT NULL,
  `Contract_id` int(11) DEFAULT NULL,
  `Contract_file` text DEFAULT NULL,
  `Image_receive` longtext DEFAULT NULL,
  `Status` int(11) DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` TEXT DEFAULT CURRENT_TIMESTAMP,
  `receipt_location` TEXT DEFAULT NULL,
  isSync int DEFAULT 0
)''';
  final sqlInitPRODUCT = '''
  CREATE TABLE `PRODUCT` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext DEFAULT NULL,
  `Detail` text DEFAULT NULL,
  `Price_sell` float DEFAULT 0,
  `Price_commission` float DEFAULT 0,
  `Price_cost` float DEFAULT 0,
  `Image` text DEFAULT NULL,
  `Image_ref` text DEFAULT NULL,
  `Category_id` int(11) DEFAULT NULL,
  `Sequence` smallint(6) DEFAULT 0,
  `Price_display` tinyint(1) DEFAULT 0,
  `Product_display` tinyint(1) DEFAULT 1,
  `Status` tinyint(1) DEFAULT 1,
  `Start_date` date DEFAULT NULL,
  `End_date` date DEFAULT NULL,
  `Condition_1` int(11) NOT NULL DEFAULT 0,
  `Condition_2` int(11) NOT NULL DEFAULT 0,
  `Condition_3` int(11) NOT NULL DEFAULT 0,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Date_edit` TEXT DEFAULT CURRENT_TIMESTAMP,
  `Timpstamp` TEXT DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitPRODUCTCANSELL = '''
  CREATE TABLE `USER_PRODUCT_CAN_SELL` (
  `User_id` int(11) NOT NULL,
  `ID` INTEGER PRIMARY KEY,
  `Product_id` int(11) NOT NULL,
  `Status` tinyint(1) NOT NULL DEFAULT 1,
  `Edit_user_id` int(11) NOT NULL,
  `Timestamp` TEXT DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitCustomerType = '''
  CREATE TABLE `CUSTOMER_TYPE` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext NOT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` TEXT DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitImageTable = '''
  CREATE TABLE IMAGE_TABLE(
  ID INTEGER PRIMARY KEY,
  IMAGE_TABLE TEXT,
  IMAGE_KEY TEXT,
  IMAGE_VALUE TEXT
  )
  ''';
  final sqlInitJsonTable = '''
  CREATE TABLE JSON_TABLE(
    ID INTEGER PRIMARY KEY,
    DATA_TABLE TEXT,
    JSON_KEY TEXT,
    JSON_VALUE TEXT
  )
  ''';
  final sqlInitCustomer = '''
  CREATE TABLE `CUSTOMER` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext DEFAULT NULL,
  `Surname` tinytext DEFAULT NULL,
  `Id_card` varchar(13) DEFAULT NULL,
  `Type_id` int(11) DEFAULT NULL,
  `Sex` tinyint(1) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `District_id` int(11) DEFAULT NULL,
  `Amphur_id` int(11) DEFAULT NULL,
  `Province_id` int(11) DEFAULT NULL,
  `Zipcode` tinytext DEFAULT NULL,
  `Birthday` date DEFAULT NULL,
  `Phone` varchar(10) DEFAULT NULL,
  `Customer_ref_no1` text DEFAULT NULL,
  `Customer_ref_no2` text DEFAULT NULL,
  `Image` text DEFAULT NULL,
  `Image_id_card` text DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` TEXT DEFAULT CURRENT_TIMESTAMP
)''';
  final sqlInitContact = '''
  CREATE TABLE `CONTRACT` (
  `ID` INTEGER PRIMARY KEY,
  `Contract_number` tinytext DEFAULT NULL,
  `Receipt_id` int(11) DEFAULT NULL,
  `Bill_id` int(11) DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Image_signature` text DEFAULT NULL,
  `Signature_date` datetime DEFAULT NULL,
  `Signature_digital` tinyint(1) DEFAULT NULL,
  `Image_signature_witness_1` text DEFAULT NULL,
  `Witness_name_1` text DEFAULT NULL,
  `Image_signature_witness_2` text DEFAULT NULL,
  `Witness_name_2` text DEFAULT NULL,
  `Other_name_1` text DEFAULT NULL,
  `Other_relationship_1` text DEFAULT NULL,
  `Other_phone_1` text DEFAULT NULL,
  `Other_name_2` text DEFAULT NULL,
  `Other_relationship_2` text DEFAULT NULL,
  `Other_phone_2` text DEFAULT NULL,
  `Book_number` text DEFAULT NULL,
  `Status` tinyint(4) NOT NULL DEFAULT 0,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
)
  ''';
  final sqlInitSettingCompany = '''
  CREATE TABLE `SETTING_COMPANY` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext NOT NULL,
  `Address` text NOT NULL,
  `Zip_code` varchar(5) NOT NULL,
  `Tax_code` varchar(13) NOT NULL,
  `Phone` text DEFAULT NULL,
  `Mobile` text DEFAULT NULL,
  `Fax` text DEFAULT NULL,
  `Email` text DEFAULT NULL,
  `Qrcodeimage` text DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Img_sign_ceo` text DEFAULT NULL,
  `Contract_name` text DEFAULT NULL,
  `Ceo_name` text DEFAULT NULL,
  `SName` text DEFAULT NULL
  )
  ''';
  final sqlInitTrail = '''
  CREATE TABLE `TRAIL` (
  `ID` INTEGER PRIMARY KEY,
  `Trial_number` tinytext DEFAULT NULL,
  `Customer_id` int(11) DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Order_detail` text DEFAULT NULL,
  `Image_receive` text DEFAULT NULL,
  `Image_signature` text DEFAULT NULL,
  `Status` tinyint(4) DEFAULT NULL,
  `Signature_date` datetime DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Date_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `trail_location` text DEFAULT NULL,
  `Sale_work_car_id` int(11) DEFAULT NULL
)
  ''';

  final sqlInitCategory = '''
  CREATE TABLE `CATEGORY` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  ) 
  ''';

  final sqlInitStockNotPrice = '''
  CREATE TABLE `STOCK_NOT_PRICE` (
  `ID` INTEGER PRIMARY KEY,
  `Name` tinytext DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `Qty` double DEFAULT NULL,
  `Exp_date` date DEFAULT NULL,
  `Status` tinyint(4) DEFAULT 1,
  `Remark` text DEFAULT NULL,
  `Edit_user_id` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  ) 
  ''';

  final sqlInitConditionOpenBillCredit ='''
  CREATE TABLE `CONDITION_OPEN_BILL_CREDIT` (
  `ID` INTEGER PRIMARY KEY,
  `Work_day_limit` int(11) DEFAULT NULL,
  `Have_bill` tinyint(1) DEFAULT NULL,
  `Rate_start` int(11) DEFAULT NULL,
  `Rate_end` int(11) DEFAULT NULL,
  `Fixed_earnest` int(11) DEFAULT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''';





}


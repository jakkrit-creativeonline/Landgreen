class TopTeam {
  int carId;
  String carPlate;
  String carNote;
  int headId;
  String headName;
  int headLevelId;
  String headImg;
  int cashCountProductCat1590;
  int cashCountProductCat1690;
  int cashCountProductCat1Other;
  int cashCountProductCat2;
  int creditCountProductCat1590;
  int creditCountProductCat1690;
  int creditCountProductCat1Other;
  int creditCountProductCat2;
  int sumCountProductCat1590;
  int sumCountProductCat1690;
  int sumCountProductCat1Other;
  int sumCountProductCat1;
  int sumCountProductCat2;
  String timeGen;
  String dayGen;
  List<SaleInCar> saleInCar;
  bool isShow;

  TopTeam(
      {this.carId,
      this.carPlate,
      this.carNote,
      this.headId,
      this.headName,
      this.headLevelId,
      this.headImg,
      this.cashCountProductCat1590,
      this.cashCountProductCat1690,
      this.cashCountProductCat1Other,
      this.cashCountProductCat2,
      this.creditCountProductCat1590,
      this.creditCountProductCat1690,
      this.creditCountProductCat1Other,
      this.creditCountProductCat2,
      this.sumCountProductCat1590,
      this.sumCountProductCat1690,
      this.sumCountProductCat1Other,
      this.sumCountProductCat1,
      this.sumCountProductCat2,
      this.timeGen,
      this.dayGen,
      this.saleInCar,
      this.isShow = false});

  TopTeam.fromJson(Map<String, dynamic> json) {
    carId = json['car_id'];
    carPlate = json['car_plate'];
    carNote = json['car_note'];
    headId = json['head_id'];
    headName = json['head_name'];
    headLevelId = json['head_level_id'];
    headImg = json['head_img'];
    cashCountProductCat1590 = json['cash_count_product_cat1_590'];
    cashCountProductCat1690 = json['cash_count_product_cat1_690'];
    cashCountProductCat1Other = json['cash_count_product_cat1_other'];
    cashCountProductCat2 = json['cash_count_product_cat2'];
    creditCountProductCat1590 = json['credit_count_product_cat1_590'];
    creditCountProductCat1690 = json['credit_count_product_cat1_690'];
    creditCountProductCat1Other = json['credit_count_product_cat1_other'];
    creditCountProductCat2 = json['credit_count_product_cat2'];
    sumCountProductCat1590 = json['sum_count_product_cat1_590'];
    sumCountProductCat1690 = json['sum_count_product_cat1_690'];
    sumCountProductCat1Other = json['sum_count_product_cat1_other'];
    sumCountProductCat1 = json['sum_count_product_cat1'];
    sumCountProductCat2 = json['sum_count_product_cat2'];
    timeGen = json['time_gen'];
    dayGen = json['day_gen'];
    if (json['sale_in_car'] != null) {
      saleInCar = new List<SaleInCar>();
      json['sale_in_car'].forEach((v) {
        saleInCar.add(new SaleInCar.fromJson(v));
      });
    }
    isShow = false;
  }
}

class SaleInCar {
  String saleName;
  int saleId;
  int saleStatus;
  String saleTimestamp;
  int cashCountProductCat1590;
  int cashCountProductCat1690;
  int cashCountProductCat1Other;
  int cashCountProductCat2;
  int cashMoneyTotal;
  int creditCountProductCat1590;
  int creditCountProductCat1690;
  int creditCountProductCat1Other;
  int creditCountProductCat2;
  int creditMoneyTotal;
  int sumCountProductCat1590;
  int sumCountProductCat1690;
  int sumCountProductCat1Other;
  int sumCountProductCat1;
  int sumCountProductCat2;
  List<BillData> billData;
  String sRowVariant;
  String sCellVariants;
  int iD;
  String username;
  String name;
  String surname;
  int workCarId;
  int levelId;
  String image;
  int goal;
  String plateNumber;
  String pROVINCENAME;

  SaleInCar(
      {this.saleName,
      this.saleId,
      this.saleStatus,
      this.saleTimestamp,
      this.cashCountProductCat1590,
      this.cashCountProductCat1690,
      this.cashCountProductCat1Other,
      this.cashCountProductCat2,
      this.cashMoneyTotal,
      this.creditCountProductCat1590,
      this.creditCountProductCat1690,
      this.creditCountProductCat1Other,
      this.creditCountProductCat2,
      this.creditMoneyTotal,
      this.sumCountProductCat1590,
      this.sumCountProductCat1690,
      this.sumCountProductCat1Other,
      this.sumCountProductCat1,
      this.sumCountProductCat2,
      this.billData,
      this.sRowVariant,
      this.sCellVariants,
      this.iD,
      this.username,
      this.name,
      this.surname,
      this.workCarId,
      this.levelId,
      this.image,
      this.goal,
      this.plateNumber,
      this.pROVINCENAME});

  SaleInCar.fromJson(Map<String, dynamic> json) {
    saleName = json['sale_name'];
    saleId = json['sale_id'];
    saleStatus = json['sale_status'];
    saleTimestamp = json['sale_timestamp'];
    cashCountProductCat1590 = json['cash_count_product_cat1_590'];
    cashCountProductCat1690 = json['cash_count_product_cat1_690'];
    cashCountProductCat1Other = json['cash_count_product_cat1_other'];
    cashCountProductCat2 = json['cash_count_product_cat2'];
    cashMoneyTotal = json['cash_money_total'];
    creditCountProductCat1590 = json['credit_count_product_cat1_590'];
    creditCountProductCat1690 = json['credit_count_product_cat1_690'];
    creditCountProductCat1Other = json['credit_count_product_cat1_other'];
    creditCountProductCat2 = json['credit_count_product_cat2'];
    creditMoneyTotal = json['credit_money_total'];
    sumCountProductCat1590 = json['sum_count_product_cat1_590'];
    sumCountProductCat1690 = json['sum_count_product_cat1_690'];
    sumCountProductCat1Other = json['sum_count_product_cat1_other'];
    sumCountProductCat1 = json['sum_count_product_cat1'];
    sumCountProductCat2 = json['sum_count_product_cat2'];
    if (json['bill_data'] != null) {
      billData = new List<BillData>();
      json['bill_data'].forEach((v) {
        billData.add(new BillData.fromJson(v));
      });
    }
    sRowVariant = json['_rowVariant'];
    sCellVariants = json['_cellVariants'];
    iD = json['ID'];
    username = json['Username'];
    name = json['Name'];
    surname = json['Surname'];
    workCarId = json['Work_car_id'];
    levelId = json['Level_id'];
    image = json['Image'];
    goal = json['Goal'];
    plateNumber = json['Plate_number'];
    pROVINCENAME = json['PROVINCE_NAME'];
  }
}

class BillData {
  int billId;
  String billNumber;
  String orderDetail;
  int status;
  int payType;
  int moneyTotal;
  int receiptId;
  String receiptNumber;

  BillData(
      {this.billId,
      this.billNumber,
      this.orderDetail,
      this.status,
      this.payType,
      this.moneyTotal,
      this.receiptId,
      this.receiptNumber});

  BillData.fromJson(Map<String, dynamic> json) {
    billId = json['Bill_id'];
    billNumber = json['Bill_number'];
    orderDetail = json['Order_detail'];
    status = json['Status'];
    payType = json['Pay_type'];
    moneyTotal = json['Money_total'];
    receiptId = json['Receipt_id'];
    receiptNumber = json['Receipt_number'];
  }
}

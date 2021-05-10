class Bill {
  var iD;
  String billNumber;
  var userId;
  var customerId;
  var payType;
  var moneyTotal;
  var moneyEarnest;
  var moneyDue;
  String dateSend;
  var dateDue;
  var datePay;
  var status;
  var commissionPay;
  var commissionSum;
  var commissionPaydate;
  String imageSignature;
  String signatureDate;
  var editUserId;
  String timestamp;
  String orderDetail;
  var creditTermId;
  var salesProvinceId;
  String dateCreate;
  var consignUserId;
  var remark;
  var idheadsale;
  var idcredit;
  var billLocation;
  var saleWorkCarId;
  var statusAppPuiya;
  var openInvoice;
  var creditChange15;
  var creditUserId;
  var isSync;

  Bill(
      {this.iD,
      this.billNumber,
      this.userId,
      this.customerId,
      this.payType,
      this.moneyTotal,
      this.moneyEarnest,
      this.moneyDue,
      this.dateSend,
      this.isSync,
      this.dateDue,
      this.datePay,
      this.status,
      this.commissionPay,
      this.commissionSum,
      this.commissionPaydate,
      this.imageSignature,
      this.signatureDate,
      this.editUserId,
      this.timestamp,
      this.orderDetail,
      this.creditTermId,
      this.salesProvinceId,
      this.dateCreate,
      this.consignUserId,
      this.remark,
      this.idheadsale,
      this.idcredit,
      this.billLocation,
      this.saleWorkCarId,
      this.statusAppPuiya,
      this.openInvoice,
      this.creditChange15,
      this.creditUserId});

  Bill.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    billNumber = json['Bill_number'];
    userId = json['User_id'];
    customerId = json['Customer_id'];
    payType = json['Pay_type'];
    moneyTotal = json['Money_total'];
    moneyEarnest = json['Money_earnest'];
    moneyDue = json['Money_due'];
    dateSend = json['Date_send'];
    dateDue = json['Date_due'];
    datePay = json['Date_pay'];
    status = json['Status'];
    commissionPay = json['Commission_pay'];
    commissionSum = json['Commission_sum'];
    commissionPaydate = json['Commission_paydate'];
    imageSignature = json['Image_signature'];
    signatureDate = json['Signature_date'];
    editUserId = (json['Edit_user_id'] == 'null')?json['User_id']:json['Edit_user_id'];
    timestamp = json['Timestamp'];
    orderDetail = json['Order_detail'];
    creditTermId = json['Credit_term_id'];
    salesProvinceId = json['Sales_province_id'];
    dateCreate = json['Date_create'];
    consignUserId = json['Consign_user_id'];
    remark = json['Remark'];
    idheadsale = json['idheadsale'];
    idcredit = json['idcredit'];
    billLocation = json['bill_location'];
    saleWorkCarId = json['Sale_work_car_id'];
    statusAppPuiya = json['Status_app_puiya'];
    openInvoice = json['Open_invoice'];
    creditChange15 = json['Credit_change15'];
    creditUserId = json['Credit_user_id'];
    isSync = json['isSync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Bill_number'] = this.billNumber;
    data['User_id'] = this.userId;
    data['Customer_id'] = this.customerId;
    data['Pay_type'] = this.payType;
    data['Money_total'] = this.moneyTotal;
    data['Money_earnest'] = this.moneyEarnest;
    data['Money_due'] = this.moneyDue;
    data['Date_send'] = this.dateSend;
    data['Date_due'] = this.dateDue;
    data['Date_pay'] = this.datePay;
    data['Status'] = this.status;
    data['Commission_pay'] = this.commissionPay;
    data['Commission_sum'] = this.commissionSum;
    data['Commission_paydate'] = this.commissionPaydate;
    data['Image_signature'] = this.imageSignature;
    data['Signature_date'] = this.signatureDate;
    data['Edit_user_id'] = this.editUserId;
    data['Timestamp'] = this.timestamp;
    data['Order_detail'] = this.orderDetail;
    data['Credit_term_id'] = this.creditTermId;
    data['Sales_province_id'] = this.salesProvinceId;
    data['Date_create'] = this.dateCreate;
    data['Consign_user_id'] = this.consignUserId;
    data['Remark'] = this.remark;
    data['idheadsale'] = this.idheadsale;
    data['idcredit'] = this.idcredit;
    data['bill_location'] = this.billLocation;
    data['Sale_work_car_id'] = this.saleWorkCarId;
    data['Status_app_puiya'] = this.statusAppPuiya;
    data['Open_invoice'] = this.openInvoice;
    data['Credit_change15'] = this.creditChange15;
    data['Credit_user_id'] = this.creditUserId;
    data['isSync'] = this.isSync;
    return data;
  }
}

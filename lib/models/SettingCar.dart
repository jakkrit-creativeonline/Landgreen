class SettingCar {
  int iD;
  String plateNumber;
  var plateProvinceId;
  var price;
  var priceRemain;
  var priceTerm;
  var note;
  var status;
  var imageRef;
  var editUserId;
  String timestamp;

  SettingCar(
      {this.iD,
        this.plateNumber,
        this.plateProvinceId,
        this.price,
        this.priceRemain,
        this.priceTerm,
        this.note,
        this.status,
        this.imageRef,
        this.editUserId,
        this.timestamp});

  SettingCar.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    plateNumber = json['Plate_number'];
    plateProvinceId = json['Plate_province_id'];
    price = json['Price'];
    priceRemain = json['Price_remain'];
    priceTerm = json['Price_term'];
    note = json['Note'];
    status = json['Status'];
    imageRef = json['Image_ref'];
    editUserId = json['Edit_user_id'];
    timestamp = json['Timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Plate_number'] = this.plateNumber;
    data['Plate_province_id'] = this.plateProvinceId;
    data['Price'] = this.price;
    data['Price_remain'] = this.priceRemain;
    data['Price_term'] = this.priceTerm;
    data['Note'] = this.note;
    data['Status'] = this.status;
    data['Image_ref'] = this.imageRef;
    data['Edit_user_id'] = this.editUserId;
    data['Timestamp'] = this.timestamp;
    return data;
  }
}

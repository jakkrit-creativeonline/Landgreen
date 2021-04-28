class Trail {
  int iD;
  String trialNumber;
  int customerId;
  int userId;
  String orderDetail;
  String imageReceive;
  String imageSignature;
  String dateCreate;
  int status;
  String name;
  String surname;
  String idCard;
  int typeId;
  int sex;
  String address;
  int districtId;
  int amphurId;
  int provinceId;
  String zipcode;
  String birthday;
  String phone;
  String customerRefNo1;
  String customerRefNo2;
  String image;
  String imageIdCard;
  int editUserId;
  String timestamp;
  String customerType;
  String pROVINCENAME;
  String dISTRICTNAME;
  String aMPHURNAME;
  String location;

  Trail(
      {this.iD,
      this.trialNumber,
      this.customerId,
      this.userId,
      this.orderDetail,
      this.imageReceive,
      this.imageSignature,
      this.dateCreate,
      this.status,
      this.name,
      this.surname,
      this.idCard,
      this.typeId,
      this.location,
      this.sex,
      this.address,
      this.districtId,
      this.amphurId,
      this.provinceId,
      this.zipcode,
      this.birthday,
      this.phone,
      this.customerRefNo1,
      this.customerRefNo2,
      this.image,
      this.imageIdCard,
      this.editUserId,
      this.timestamp,
      this.customerType,
      this.pROVINCENAME,
      this.dISTRICTNAME,
      this.aMPHURNAME});

  Trail.fromJson(Map<String, dynamic> json) {
    iD = json['Trail_id'];
    trialNumber = json['Trial_number'];
    customerId = json['Customer_id'];
    userId = json['User_id'];
    orderDetail = json['Order_detail'];
    imageReceive = json['Image_receive'];
    imageSignature = json['Image_signature'];
    dateCreate = json['Date_create'];
    status = json['Status'];
    name = json['Name'];
    surname = json['Surname'];
    idCard = json['Id_card'];
    location = json['trail_location'];
    typeId = json['Type_id'];
    sex = json['Sex'];
    address = json['Address'];
    districtId = json['District_id'];
    amphurId = json['Amphur_id'];
    provinceId = json['Province_id'];
    zipcode = json['Zipcode'];
    birthday = json['Birthday'];
    phone = json['Phone'];
    customerRefNo1 = json['Customer_ref_no1'];
    customerRefNo2 = json['Customer_ref_no2'];
    image = json['Image'];
    imageIdCard = json['Image_id_card'];
    editUserId = json['Edit_user_id'];
    timestamp = json['Trail_timestamp'];
  }
}

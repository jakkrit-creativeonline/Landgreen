class User {
  int iD;
  String username;
  String password;
  int levelId;
  String name;
  String surname;
  String idCard;
  var settingCommission;
  var settingRecommend;
  String workDateStart;
  var workTeamUserId;
  var workManagerUserId;
  var workCarNumber;
  var workStatus;
  var workCarId;
  var goal;
  var editUserId;
  var bankId;
  String bankAccount;
  String address;
  var districtId;
  var amphurId;
  var provinceId;
  var sex;
  String birthday;
  var userIdRecommend;
  String image;
  var imageIdCard;
  var beforeAfterType;
  var settingCommissionPercent;
  var salesProvinceId;
  String timestamp;
  var saleVipTeamId;

  User(
      {this.iD,
        this.username,
        this.password,
        this.levelId,
        this.name,
        this.surname,
        this.idCard,
        this.settingCommission,
        this.settingRecommend,
        this.workDateStart,
        this.workTeamUserId,
        this.workManagerUserId,
        this.workCarNumber,
        this.workStatus,
        this.workCarId,
        this.goal,
        this.editUserId,
        this.bankId,
        this.bankAccount,
        this.address,
        this.districtId,
        this.amphurId,
        this.provinceId,
        this.sex,
        this.birthday,
        this.userIdRecommend,
        this.image,
        this.imageIdCard,
        this.beforeAfterType,
        this.settingCommissionPercent,
        this.salesProvinceId,
        this.timestamp,
        this.saleVipTeamId});

  User.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    username = json['Username'];
    password = json['Password'];
    levelId = json['Level_id'];
    name = json['Name'];
    surname = json['Surname'];
    idCard = json['Id_card'];
    settingCommission = json['Setting_commission'];
    settingRecommend = json['Setting_recommend'];
    workDateStart = json['Work_date_start'];
    workTeamUserId = json['Work_team_user_id'];
    workManagerUserId = json['Work_manager_user_id'];
    workCarNumber = json['Work_car_number'];
    workStatus = json['Work_status'];
    workCarId = json['Work_car_id'];
    goal = json['Goal'];
    editUserId = json['Edit_user_id'];
    bankId = json['Bank_id'];
    bankAccount = json['Bank_account'];
    address = json['Address'];
    districtId = json['District_id'];
    amphurId = json['Amphur_id'];
    provinceId = json['Province_id'];
    sex = json['Sex'];
    birthday = json['Birthday'];
    userIdRecommend = json['User_id_recommend'];
    image = json['Image'];
    imageIdCard = json['Image_id_card'];
    beforeAfterType = json['Before_after_type'];
    settingCommissionPercent = json['Setting_commission_percent'];
    salesProvinceId = json['Sales_Province_id'];
    timestamp = json['Timestamp'];
    saleVipTeamId = json['Sale_vip_team_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Username'] = this.username;
    data['Password'] = this.password;
    data['Level_id'] = this.levelId;
    data['Name'] = this.name;
    data['Surname'] = this.surname;
    data['Id_card'] = this.idCard;
    data['Setting_commission'] = this.settingCommission;
    data['Setting_recommend'] = this.settingRecommend;
    data['Work_date_start'] = this.workDateStart;
    data['Work_team_user_id'] = this.workTeamUserId;
    data['Work_manager_user_id'] = this.workManagerUserId;
    data['Work_car_number'] = this.workCarNumber;
    data['Work_status'] = this.workStatus;
    data['Work_car_id'] = this.workCarId;
    data['Goal'] = this.goal;
    data['Edit_user_id'] = this.editUserId;
    data['Bank_id'] = this.bankId;
    data['Bank_account'] = this.bankAccount;
    data['Address'] = this.address;
    data['District_id'] = this.districtId;
    data['Amphur_id'] = this.amphurId;
    data['Province_id'] = this.provinceId;
    data['Sex'] = this.sex;
    data['Birthday'] = this.birthday;
    data['User_id_recommend'] = this.userIdRecommend;
    data['Image'] = this.image;
    data['Image_id_card'] = this.imageIdCard;
    data['Before_after_type'] = this.beforeAfterType;
    data['Setting_commission_percent'] = this.settingCommissionPercent;
    data['Sales_Province_id'] = this.salesProvinceId;
    data['Timestamp'] = this.timestamp;
    data['Sale_vip_team_id'] = this.saleVipTeamId;
    return data;
  }
}

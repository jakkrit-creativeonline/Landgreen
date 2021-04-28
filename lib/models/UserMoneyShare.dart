class UserMoneyShare {
  var userId;
  var iD;
  var moneyShareTypeId;
  String moneyShareTypeName;
  var money;
  var toUserId;
  String userName;
  var userLevelId;
  String userLevelName;
  var status;
  var editUserId;
  String timestamp;

  UserMoneyShare(
      {this.userId,
        this.iD,
        this.moneyShareTypeId,
        this.moneyShareTypeName,
        this.money,
        this.toUserId,
        this.userName,
        this.userLevelId,
        this.userLevelName,
        this.status,
        this.editUserId,
        this.timestamp});

  UserMoneyShare.fromJson(Map<String, dynamic> json) {
    userId = json['User_id'];
    iD = json['ID'];
    moneyShareTypeId = json['Money_share_type_id'];
    moneyShareTypeName = json['Money_share_type_name'];
    money = json['Money'];
    toUserId = json['To_user_id'];
    userName = json['User_name'];
    userLevelId = json['User_Level_id'];
    userLevelName = json['User_Level_name'];
    status = json['Status'];
    editUserId = json['Edit_user_id'];
    timestamp = json['Timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['User_id'] = this.userId;
    data['ID'] = this.iD;
    data['Money_share_type_id'] = this.moneyShareTypeId;
    data['Money_share_type_name'] = this.moneyShareTypeName;
    data['Money'] = this.money;
    data['To_user_id'] = this.toUserId;
    data['User_name'] = this.userName;
    data['User_Level_id'] = this.userLevelId;
    data['User_Level_name'] = this.userLevelName;
    data['Status'] = this.status;
    data['Edit_user_id'] = this.editUserId;
    data['Timestamp'] = this.timestamp;
    return data;
  }
}

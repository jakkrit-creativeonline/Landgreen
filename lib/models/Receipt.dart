class Receipt {
  String receiptNumber;
  String receiptImageSignature;
  String receiptSignatureDate;
  String imageReceive;
  int receiptStatus;
  int receiptEditUserId;
  String receiptTimestamp;
  int receiptId;
  String billNumber;
  int iD;
  String contractNumber;
  int billId;
  int userId;
  String imageSignature;
  String signatureDate;
  var signatureDigital;
  String imageSignatureWitness1;
  String witnessName1;
  String imageSignatureWitness2;
  String witnessName2;
  String otherName1;
  String otherRelationship1;
  String otherPhone1;
  String otherName2;
  String otherRelationship2;
  String otherPhone2;
  String bookNumber;
  int status;
  int editUserId;
  String timestamp;
  int isSync;
  String location;

  Receipt(
      {this.receiptNumber,
      this.receiptImageSignature,
      this.receiptSignatureDate,
      this.imageReceive,
      this.receiptStatus,
      this.receiptEditUserId,
      this.receiptTimestamp,
      this.location,
      this.receiptId,
      this.billNumber,
      this.iD,
      this.contractNumber,
      this.billId,
      this.userId,
      this.imageSignature,
      this.signatureDate,
      this.signatureDigital,
      this.imageSignatureWitness1,
      this.witnessName1,
      this.imageSignatureWitness2,
      this.witnessName2,
      this.otherName1,
      this.otherRelationship1,
      this.otherPhone1,
      this.otherName2,
      this.otherRelationship2,
      this.otherPhone2,
      this.bookNumber,
      this.status,
      this.editUserId,
      this.timestamp,
      this.isSync});

  Receipt.fromJson(Map<String, dynamic> json) {
    receiptNumber = json['Receipt_number'];
    receiptImageSignature = json['Receipt_image_signature'];
    receiptSignatureDate = json['Receipt_signature_date'];
    imageReceive = json['Image_receive'];
    receiptStatus = json['Receipt_status'];
    receiptEditUserId = json['Receipt_edit_user_id'];
    receiptTimestamp = json['Receipt_timestamp'];
    receiptId = json['ReceiptId'];
    billNumber = json['Bill_number'];
    iD = json['ID'];
    location = json['receipt_location'];
    contractNumber = json['Contract_number'];
    billId = json['Bill_id'];
    userId = json['UserId'];
    imageSignature = json['Image_signature'];
    signatureDate = json['Signature_date'];
    signatureDigital = json['Signature_digital'];
    imageSignatureWitness1 = json['Image_signature_witness_1'];
    witnessName1 = json['Witness_name_1'];
    imageSignatureWitness2 = json['Image_signature_witness_2'];
    witnessName2 = json['Witness_name_2'];
    otherName1 = json['Other_name_1'];
    otherRelationship1 = json['Other_relationship_1'];
    otherPhone1 = json['Other_phone_1'];
    otherName2 = json['Other_name_2'];
    otherRelationship2 = json['Other_relationship_2'];
    otherPhone2 = json['Other_phone_2'];
    bookNumber = json['Book_number'];
    status = json['Status'];
    editUserId = json['Edit_user_id'];
    timestamp = json['Timestamp'];
    isSync = json['isSync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Receipt_number'] = this.receiptNumber;
    data['Receipt_image_signature'] = this.receiptImageSignature;
    data['Receipt_signature_date'] = this.receiptSignatureDate;
    data['Image_receive'] = this.imageReceive;
    data['Receipt_status'] = this.receiptStatus;
    data['Receipt_edit_user_id'] = this.receiptEditUserId;
    data['Receipt_timestamp'] = this.receiptTimestamp;
    data['ReceiptId'] = this.receiptId;
    data['Bill_number'] = this.billNumber;
    data['ID'] = this.iD;
    data['Contract_number'] = this.contractNumber;
    data['Bill_id'] = this.billId;
    data['UserId'] = this.userId;
    data['Image_signature'] = this.imageSignature;
    data['Signature_date'] = this.signatureDate;
    data['Signature_digital'] = this.signatureDigital;
    data['Image_signature_witness_1'] = this.imageSignatureWitness1;
    data['Witness_name_1'] = this.witnessName1;
    data['Image_signature_witness_2'] = this.imageSignatureWitness2;
    data['Witness_name_2'] = this.witnessName2;
    data['Other_name_1'] = this.otherName1;
    data['Other_relationship_1'] = this.otherRelationship1;
    data['Other_phone_1'] = this.otherPhone1;
    data['Other_name_2'] = this.otherName2;
    data['Other_relationship_2'] = this.otherRelationship2;
    data['Other_phone_2'] = this.otherPhone2;
    data['Book_number'] = this.bookNumber;
    data['Status'] = this.status;
    data['Edit_user_id'] = this.editUserId;
    data['Timestamp'] = this.timestamp;
    data['isSync'] = this.isSync;
    return data;
  }
}

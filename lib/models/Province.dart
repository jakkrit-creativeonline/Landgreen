class Province {
  int pROVINCEID;
  String pROVINCECODE;
  String pROVINCENAME;
  int gEOID;

  Province({this.pROVINCEID, this.pROVINCECODE, this.pROVINCENAME, this.gEOID});

  Province.fromJson(Map<String, dynamic> json) {
    pROVINCEID = json['PROVINCE_ID'];
    pROVINCECODE = json['PROVINCE_CODE'];
    pROVINCENAME = json['PROVINCE_NAME'];
    gEOID = json['GEO_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PROVINCE_ID'] = this.pROVINCEID;
    data['PROVINCE_CODE'] = this.pROVINCECODE;
    data['PROVINCE_NAME'] = this.pROVINCENAME;
    data['GEO_ID'] = this.gEOID;
    return data;
  }

  speak() {
    print('ProvinceId : $pROVINCEID , ProvinceName : $pROVINCENAME');
  }

  //bool findById(String filter) {}

  bool isEqual(Province model) {
    return this?.pROVINCEID == model?.pROVINCEID;
  }

  bool provinceFilterByName(String filter) {
    return this?.pROVINCENAME?.toString()?.contains(filter);
  }

  bool provinceFilterById(String filter) {
    return this?.pROVINCEID?.toString()?.contains(filter);
  }

  bool operator ==(o) =>
      o is Province &&
      o.pROVINCENAME == pROVINCENAME &&
      o.pROVINCEID == pROVINCEID;

  @override
  String toString() => pROVINCENAME;
}

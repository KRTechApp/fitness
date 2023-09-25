/// language_list : [{"language_id":1,"language_title":"English","language_code":"en"}]

class LanguageListData {
  LanguageListData({
      List<LanguageItem>? languageList,}){
    _languageList = languageList;
}

  LanguageListData.fromJson(dynamic json) {
    if (json['language_list'] != null) {
      _languageList = [];
      json['language_list'].forEach((v) {
        _languageList?.add(LanguageItem.fromJson(v));
      });
    }
  }
  List<LanguageItem>? _languageList;

  List<LanguageItem>? get languageList => _languageList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_languageList != null) {
      map['language_list'] = _languageList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// language_id : 1
/// language_title : "English"
/// language_code : "en"

class LanguageItem {
  LanguageItem({
      int? languageId, 
      String? languageTitle, 
      String? languageCode,}){
    _languageId = languageId;
    _languageTitle = languageTitle;
    _languageCode = languageCode;
}

  LanguageItem.fromJson(dynamic json) {
    _languageId = json['language_id'];
    _languageTitle = json['language_title'];
    _languageCode = json['language_code'];
  }
  int? _languageId;
  String? _languageTitle;
  String? _languageCode;

  int? get languageId => _languageId;
  String? get languageTitle => _languageTitle;
  String? get languageCode => _languageCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['language_id'] = _languageId;
    map['language_title'] = _languageTitle;
    map['language_code'] = _languageCode;
    return map;
  }

}
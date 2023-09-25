/// id : ""
/// day : ""
/// fullName : ""

class AddClassSelectDays {
  AddClassSelectDays({
      String? id, 
      String? day, 
      String? fullName,}){
    _id = id;
    _day = day;
    _fullName = fullName;
}

  AddClassSelectDays.fromJson(dynamic json) {
    _id = json['id'];
    _day = json['day'];
    _fullName = json['fullName'];
  }
  String? _id;
  String? _day;
  String? _fullName;
AddClassSelectDays copyWith({  String? id,
  String? day,
  String? fullName,
}) => AddClassSelectDays(  id: id ?? _id,
  day: day ?? _day,
  fullName: fullName ?? _fullName,
);
  String? get id => _id;
  String? get day => _day;
  String? get fullName => _fullName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['day'] = _day;
    map['fullName'] = _fullName;
    return map;
  }

}
/// selected_member : [""]
/// unselected_member : [""]
/// already_selected_member : [""]

class MemberSelectionModel {
  MemberSelectionModel({
      this.selectedMember,
      this.unselectedMember,
      this.alreadySelectedMember,});

  MemberSelectionModel.fromJson(dynamic json) {
    selectedMember = json['selected_member'] != null ? json['selected_member'].cast<String>() : [];
    unselectedMember = json['unselected_member'] != null ? json['unselected_member'].cast<String>() : [];
    alreadySelectedMember = json['already_selected_member'] != null ? json['already_selected_member'].cast<String>() : [];
  }
  List<String>? selectedMember = [];
  List<String>? unselectedMember = [];
  List<String>? alreadySelectedMember = [];
MemberSelectionModel copyWith({  List<String>? selectedMember,
  List<String>? unselectedMember,
  List<String>? alreadySelectedMember,
}) => MemberSelectionModel(  selectedMember: selectedMember ?? this.selectedMember,
  unselectedMember: unselectedMember ?? this.unselectedMember,
  alreadySelectedMember: alreadySelectedMember ?? this.alreadySelectedMember,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['selected_member'] = selectedMember;
    map['unselected_member'] = unselectedMember;
    map['already_selected_member'] = alreadySelectedMember;
    return map;
  }

}
/// id : ""
/// set : ""
/// reps : ""
/// sec : ""
/// rest : ""

class ExerciseDataModel {
  ExerciseDataModel({
      String? id, 
      String? set, 
      String? reps, 
      String? sec, 
      String? rest,}){
    exerciseDataId = id;
    exerciseDataSet = set;
    exerciseDataReps = reps;
    exerciseDataSec = sec;
    exerciseDataRest = rest;
}

  ExerciseDataModel.fromJson(dynamic json) {
    exerciseDataId = json['id'];
    exerciseDataSet = json['set'];
    exerciseDataReps = json['reps'];
    exerciseDataSec = json['sec'];
    exerciseDataRest = json['rest'];
  }
  String? exerciseDataId;
  String? exerciseDataSet;
  String? exerciseDataReps;
  String? exerciseDataSec;
  String? exerciseDataRest;
ExerciseDataModel copyWith({  String? id,
  String? set,
  String? reps,
  String? sec,
  String? rest,
}) => ExerciseDataModel(  id: id ?? exerciseDataId,
  set: set ?? exerciseDataSet,
  reps: reps ?? exerciseDataReps,
  sec: sec ?? exerciseDataSec,
  rest: rest ?? exerciseDataRest,
);
  String? get id => exerciseDataId;
  String? get set => exerciseDataSet;
  String? get reps => exerciseDataReps;
  String? get sec => exerciseDataSec;
  String? get rest => exerciseDataRest;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = exerciseDataId;
    map['set'] = exerciseDataSet;
    map['reps'] = exerciseDataReps;
    map['sec'] = exerciseDataSec;
    map['rest'] = exerciseDataRest;
    return map;
  }

}
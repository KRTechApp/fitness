/// exerciseDataList : [{"exerciseId":"S1Md8k40KxWr3q4vQqcp","categoryId":"S1Md8k40KxWr3q4vQqcp","id":"S1Md8k40KxWr3q4vQqcp","set":"3","reps":"5","sec":"30","rest":"30","dayList":["sunday"]}]

class WorkoutDaysModel {
  WorkoutDaysModel({
      List<ExerciseDataItem>? exerciseDataList = const [],}){
    addExerciseDataList = exerciseDataList;
}

  WorkoutDaysModel.fromJson(dynamic json) {
    if (json['exerciseDataList'] != null) {
      addExerciseDataList = [];
      json['exerciseDataList'].forEach((v) {
        addExerciseDataList?.add(ExerciseDataItem.fromJson(v));
      });
    }
  }
  List<ExerciseDataItem>? addExerciseDataList;
WorkoutDaysModel copyWith({  List<ExerciseDataItem>? exerciseDataList,
}) => WorkoutDaysModel(  exerciseDataList: exerciseDataList ?? addExerciseDataList,
);
  List<ExerciseDataItem>? get exerciseDataList => addExerciseDataList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (addExerciseDataList != null) {
      map['exerciseDataList'] = addExerciseDataList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// exerciseId : "S1Md8k40KxWr3q4vQqcp"
/// categoryId : "S1Md8k40KxWr3q4vQqcp"
/// set : "3"
/// reps : "5"
/// sec : "30"
/// rest : "30"
/// dayList : ["sunday"]

class ExerciseDataItem {
  ExerciseDataItem({
    String? exerciseId = "",
    String? categoryId = "",
    String? set = "",
    String? reps = "",
    String? sec = "",
    String? rest = "",
    String? weight = "",
    List<String>? dayList = const [],}){
    exerciseDataId = exerciseId;
    categoryDataId = categoryId;
    exerciseDataSet = set;
    exerciseDataReps = reps;
    exerciseDataSec = sec;
    exerciseDataRest = rest;
    exerciseDataWeight = weight;
    dayDataList = dayList;
  }

  ExerciseDataItem.fromJson(dynamic json) {
    exerciseDataId = json['exerciseId'];
    categoryDataId = json['categoryId'];
    exerciseDataSet = json['set'];
    exerciseDataReps = json['reps'];
    exerciseDataSec = json['sec'];
    exerciseDataRest = json['rest'];
    exerciseDataWeight = json['weight'];
    dayDataList = json['dayList'] != null ? json['dayList'].cast<String>() : [];
  }
  String? exerciseDataId;
  String? categoryDataId;
  String? exerciseDataSet;
  String? exerciseDataReps;
  String? exerciseDataSec;
  String? exerciseDataRest;
  String? exerciseDataWeight;
  List<String>? dayDataList;
  ExerciseDataItem copyWith({  String? exerciseId,
    String? categoryId,
    String? set,
    String? reps,
    String? sec,
    String? rest,
    String? weight,
    List<String>? dayList,
  }) => ExerciseDataItem(  exerciseId: exerciseId ?? exerciseDataId,
    categoryId: categoryId ?? categoryDataId,
    set: set ?? exerciseDataSet,
    reps: reps ?? exerciseDataReps,
    sec: sec ?? exerciseDataSec,
    rest: rest ?? exerciseDataRest,
    weight: weight ?? exerciseDataWeight,
    dayList: dayList ?? dayDataList,
  );
  String? get exerciseId => exerciseDataId;
  String? get categoryId => categoryDataId;
  String? get set => exerciseDataSet;
  String? get reps => exerciseDataReps;
  String? get sec => exerciseDataSec;
  String? get rest => exerciseDataRest;
  String? get weight => exerciseDataWeight;
  List<String>? get dayList => dayDataList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exerciseId'] = exerciseDataId;
    map['categoryId'] = categoryDataId;
    map['set'] = exerciseDataSet;
    map['reps'] = exerciseDataReps;
    map['sec'] = exerciseDataSec;
    map['rest'] = exerciseDataRest;
    map['weight'] = exerciseDataWeight;
    map['dayList'] = dayDataList;
    return map;
  }

}
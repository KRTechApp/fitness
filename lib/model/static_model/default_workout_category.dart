/// workout_category_list : [{"id":"1","title":"Yoga","profile":"assets/default_data/default_image/yoga/trikonasana.png"},{"id":"2","title":"Zumba","profile":"assets/default_data/default_image/zumba/merengue.png"},{"id":"3","title":"Cross Fit","profile":"assets/default_data/default_image/cross_fit/deadlifts.png"},{"id":"4","title":"Body Building","profile":"assets/default_data/default_image/body_building/barbell_biceps_curl.png"},{"id":"5","title":"Weight Loose","profile":"assets/default_data/default_image/weight_loose/jumping_jacks.png"},{"id":"6","title":"Cardio","profile":"assets/default_data/default_image/cardio/burpees.png"}]

class DefaultWorkoutCategory {
  DefaultWorkoutCategory({
      List<WorkoutCategoryList>? workoutCategoryList,}){
    _workoutCategoryList = workoutCategoryList;
}

  DefaultWorkoutCategory.fromJson(dynamic json) {
    if (json['workout_category_list'] != null) {
      _workoutCategoryList = [];
      json['workout_category_list'].forEach((v) {
        _workoutCategoryList?.add(WorkoutCategoryList.fromJson(v));
      });
    }
  }
  List<WorkoutCategoryList>? _workoutCategoryList;
DefaultWorkoutCategory copyWith({  List<WorkoutCategoryList>? workoutCategoryList,
}) => DefaultWorkoutCategory(  workoutCategoryList: workoutCategoryList ?? _workoutCategoryList,
);
  List<WorkoutCategoryList>? get workoutCategoryList => _workoutCategoryList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_workoutCategoryList != null) {
      map['workout_category_list'] = _workoutCategoryList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "1"
/// title : "Yoga"
/// profile : "assets/default_data/default_image/yoga/trikonasana.png"

class WorkoutCategoryList {
  WorkoutCategoryList({
      String? id, 
      String? docId,
      String? title,
      String? profile,}){
    _id = id;
    setDocId = docId;
    _title = title;
    _profile = profile;
}

  WorkoutCategoryList.fromJson(dynamic json) {
    _id = json['id'];
    setDocId= json['docId'];
    _title = json['title'];
    _profile = json['profile'];
  }
  String? _id;
  String? setDocId;
  String? _title;
  String? _profile;
WorkoutCategoryList copyWith({  String? id,String? docId,
  String? title,
  String? profile,
}) => WorkoutCategoryList(  id: id ?? _id,
  title: title ?? _title,
  docId: docId ?? setDocId,
  profile: profile ?? _profile,
);
  String? get id => _id;
  String? get docId => setDocId;
  String? get title => _title;
  String? get profile => _profile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['docId'] = setDocId;
    map['title'] = _title;
    map['profile'] = _profile;
    return map;
  }

}
/// exercise_list : [{"exercise_id":"1","category_id":"1","exercise_title":"Tadasana","profile":"assets/default_data/default_image/yoga/tadasana.png"},{"exercise_id":"2","category_id":"1","exercise_title":"Utkatasana","profile":"assets/default_data/default_image/yoga/utkatasana.png"},{"exercise_id":"3","category_id":"1","exercise_title":"Uttana shishosana","profile":"assets/default_data/default_image/yoga/uttana_shishosana.png"},{"exercise_id":"4","category_id":"1","exercise_title":"Adho Mukha Svanasana","profile":"assets/default_data/default_image/yoga/adho_mukha_svanasana.png"},{"exercise_id":"5","category_id":"1","exercise_title":"Virabhadrasana","profile":"assets/default_data/default_image/yoga/virabhadrasana.png"},{"exercise_id":"6","category_id":"1","exercise_title":"Trikonasana","profile":"assets/default_data/default_image/yoga/trikonasana.png"},{"exercise_id":"7","category_id":"1","exercise_title":"Vrksasana","profile":"assets/default_data/default_image/yoga/vrksasana.png"},{"exercise_id":"8","category_id":"2","exercise_title":"Merengue","profile":"assets/default_data/default_image/zumba/merengue.png"},{"exercise_id":"9","category_id":"2","exercise_title":"Salsa","profile":"assets/default_data/default_image/zumba/salsa.png"},{"exercise_id":"10","category_id":"2","exercise_title":"Cumbia","profile":"assets/default_data/default_image/zumba/cumbia.png"},{"exercise_id":"11","category_id":"2","exercise_title":"Reggaeton","profile":"assets/default_data/default_image/zumba/reggaeton.png"},{"exercise_id":"12","category_id":"2","exercise_title":"Bachata","profile":"assets/default_data/default_image/zumba/bachata.png"},{"exercise_id":"13","category_id":"2","exercise_title":"Samba","profile":"assets/default_data/default_image/zumba/samba.png"},{"exercise_id":"14","category_id":"2","exercise_title":"Bellydance","profile":"assets/default_data/default_image/zumba/belly_dance.png"},{"exercise_id":"15","category_id":"3","exercise_title":"Deadlifts","profile":"assets/default_data/default_image/cross_fit/deadlifts.png"},{"exercise_id":"16","category_id":"3","exercise_title":"Overhead thrusters","profile":"assets/default_data/default_image/cross_fit/overhead_thrusters.png"},{"exercise_id":"17","category_id":"3","exercise_title":"Handstand pushups","profile":"assets/default_data/default_image/cross_fit/handstand_pushups.png"},{"exercise_id":"18","category_id":"3","exercise_title":"Wall balls","profile":"assets/default_data/default_image/cross_fit/wall_balls.png"},{"exercise_id":"19","category_id":"3","exercise_title":"Box jumps","profile":"assets/default_data/default_image/cross_fit/box_jumps.png"},{"exercise_id":"20","category_id":"3","exercise_title":"Front squat","profile":"assets/default_data/default_image/cross_fit/front_squat.png"},{"exercise_id":"21","category_id":"3","exercise_title":"Overhead press","profile":"assets/default_data/default_image/cross_fit/overhead_press.png"},{"exercise_id":"22","category_id":"4","exercise_title":"Pull-Up","profile":"assets/default_data/default_image/body_building/pull_up.png"},{"exercise_id":"23","category_id":"4","exercise_title":"Dumbbell Shoulder Press","profile":"assets/default_data/default_image/body_building/dumbbell_shoulder_press.png"},{"exercise_id":"24","category_id":"4","exercise_title":"Triceps Dip","profile":"assets/default_data/default_image/body_building/triceps_dip.png"},{"exercise_id":"25","category_id":"4","exercise_title":"Incline Dumbbell Press","profile":"assets/default_data/default_image/body_building/incline_dumbbell_press.png"},{"exercise_id":"26","category_id":"4","exercise_title":"Barbell Row","profile":""},{"exercise_id":"27","category_id":"4","exercise_title":"Barbell Biceps Curl","profile":"assets/default_data/default_image/body_building/barbell_biceps_curl.png"},{"exercise_id":"28","category_id":"4","exercise_title":"Standing Calf Raise","profile":"assets/default_data/default_image/body_building/standing_calf_raise.png"},{"exercise_id":"29","category_id":"5","exercise_title":"Walking","profile":"assets/default_data/default_image/weight_loose/walking.png"},{"exercise_id":"30","category_id":"5","exercise_title":"Jogging","profile":"assets/default_data/default_image/weight_loose/jogging.png"},{"exercise_id":"31","category_id":"5","exercise_title":"Cycling","profile":"assets/default_data/default_image/weight_loose/cycling.png"},{"exercise_id":"32","category_id":"5","exercise_title":"Swimming","profile":"assets/default_data/default_image/weight_loose/swimming.jpg"},{"exercise_id":"33","category_id":"5","exercise_title":"Jumping Jacks","profile":"assets/default_data/default_image/weight_loose/jumping_jacks.png"},{"exercise_id":"34","category_id":"5","exercise_title":"Agility Ladder","profile":"assets/default_data/default_image/weight_loose/agility_ladder.jpg"},{"exercise_id":"35","category_id":"5","exercise_title":"Pilates","profile":"assets/default_data/default_image/weight_loose/pilates.png"},{"exercise_id":"36","category_id":"6","exercise_title":"Froggy jumps","profile":"assets/default_data/default_image/cardio/froggy_jumps.png"},{"exercise_id":"37","category_id":"6","exercise_title":"Burpees","profile":"assets/default_data/default_image/cardio/burpees.png"},{"exercise_id":"38","category_id":"6","exercise_title":"Toe taps with jumps","profile":"assets/default_data/default_image/cardio/toe_taps_with_jumps.png"},{"exercise_id":"39","category_id":"6","exercise_title":"Side to side jumping lunges","profile":"assets/default_data/default_image/cardio/jumping_lunges.png"},{"exercise_id":"40","category_id":"6","exercise_title":"Long jumps","profile":"assets/default_data/default_image/cardio/long_jumps.png"},{"exercise_id":"41","category_id":"6","exercise_title":"Jumping Jacks to a Step","profile":"assets/default_data/default_image/cardio/jumping_Jacks.png"},{"exercise_id":"42","category_id":"6","exercise_title":"Prisoner Squat Jumps","profile":"assets/default_data/default_image/cardio/prisoner_squat_jumps.png"}]

class DefaultExercise {
  DefaultExercise({
      List<ExerciseList>? exerciseList,}){
    _exerciseList = exerciseList;
}

  DefaultExercise.fromJson(dynamic json) {
    if (json['exercise_list'] != null) {
      _exerciseList = [];
      json['exercise_list'].forEach((v) {
        _exerciseList?.add(ExerciseList.fromJson(v));
      });
    }
  }
  List<ExerciseList>? _exerciseList;
DefaultExercise copyWith({  List<ExerciseList>? exerciseList,
}) => DefaultExercise(  exerciseList: exerciseList ?? _exerciseList,
);
  List<ExerciseList>? get exerciseList => _exerciseList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_exerciseList != null) {
      map['exercise_list'] = _exerciseList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// exercise_id : "1"
/// category_id : "1"
/// exercise_title : "Tadasana"
/// profile : "assets/default_data/default_image/yoga/tadasana.png"

class ExerciseList {
  ExerciseList({
      String? exerciseId, 
      String? docExerciseId,
      String? categoryId,
      String? exerciseTitle, 
      String? description,
      String? profile,String? youtubeLink,}){
    _exerciseId = exerciseId;
    setDocExerciseId = docExerciseId;
    _categoryId = categoryId;
    _exerciseTitle = exerciseTitle;
    _description = description;
    _profile = profile;
    _youtubeLink = youtubeLink;
}

  ExerciseList.fromJson(dynamic json) {
    _exerciseId = json['exercise_id'];
    setDocExerciseId = json['docExerciseId'];
    _categoryId = json['category_id'];
    _exerciseTitle = json['exercise_title'];
    _description = json['description'];
    _profile = json['profile'];
    _youtubeLink = json['youtube_link'];
  }
  String? _exerciseId;
  String? setDocExerciseId;
  String? _categoryId;
  String? _exerciseTitle;
  String? _description;
  String? _profile;
  String? _youtubeLink;
ExerciseList copyWith({  String? exerciseId,
  String? categoryId,
  String? docExerciseId,
  String? exerciseTitle,
  String? description,
  String? profile,
  String? youtubeLink,
}) => ExerciseList(  exerciseId: exerciseId ?? _exerciseId,
  categoryId: categoryId ?? _categoryId,
  docExerciseId: docExerciseId ?? setDocExerciseId,
  exerciseTitle: exerciseTitle ?? _exerciseTitle,
  description: description ?? _description,
  profile: profile ?? _profile,
  youtubeLink: youtubeLink ?? _youtubeLink,
);
  String? get exerciseId => _exerciseId;
  String? get docExerciseId => setDocExerciseId;
  String? get categoryId => _categoryId;
  String? get exerciseTitle => _exerciseTitle;
  String? get description => _description;
  String? get profile => _profile;
  String? get youtubeLink => _youtubeLink;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exercise_id'] = _exerciseId;
    map['docExerciseId'] = docExerciseId;
    map['category_id'] = _categoryId;
    map['exercise_title'] = _exerciseTitle;
    map['description'] = _description;
    map['profile'] = _profile;
    map['youtube_link'] = _youtubeLink;
    return map;
  }

}
import 'dart:ffi';
import 'dart:io';

/// image : ""
/// exerciseTitle : ""
/// description : ""
/// video : ""
/// youtubeLink : ""
/// notes : ""
/// set : ""
/// reps : ""
/// sec : ""
/// rest : ""
/// isSelected : ""
/// position : ""

class ExerciseModel {
  ExerciseModel({
    File? profileImageFile,
    String? profileImage,
    String? exerciseTitle,
    String? description,
    File? exerciseDetailImageFile,
    String? exerciseDetailImage,
    String? youtubeLink,
    String? notes,
  }) {
    profilesImageFile = profileImageFile;
    profilesImage = profileImage;
    exerciseExerciseTitle = exerciseTitle;
    exerciseDescription = description;
    exerciseImageFile = exerciseDetailImageFile;
    exerciseImage = exerciseDetailImage;
    exerciseYoutubeLink = youtubeLink;
    exerciseNotes = notes;
  }

  ExerciseModel.fromJson(dynamic json) {
    profilesImageFile = json['imageFile'];
    profilesImage = json['image'];
    exerciseExerciseTitle = json['exerciseTitle'];
    exerciseDescription = json['description'];
    exerciseImageFile = json['exerciseImageFile'];
    exerciseImage = json['exerciseImage'];
    exerciseYoutubeLink = json['youtubeLink'];
    exerciseNotes = json['notes'];
  }

  File? profilesImageFile;
  String? profilesImage;
  String? exerciseExerciseTitle;
  String? exerciseDescription;
  File? exerciseImageFile;
  String? exerciseImage;
  String? exerciseYoutubeLink;
  String? exerciseNotes;

  ExerciseModel copyWith({
    File? profileImageFile,
    String? profileImage,
    String? exerciseTitle,
    String? description,
    File? exerciseDetailImageFile,
    String? exerciseDetailImage,
    String? youtubeLink,
    String? notes,
    String? set,
    String? reps,
    String? sec,
    String? rest,
    Bool? isSelected,
    Int? position,
  }) =>
      ExerciseModel(
        profileImageFile: profileImageFile ?? profilesImageFile,
        profileImage: profileImage ?? profilesImage,
        exerciseTitle: exerciseTitle ?? exerciseExerciseTitle,
        description: description ?? exerciseDescription,
        exerciseDetailImageFile: exerciseDetailImageFile ?? exerciseImageFile,
        exerciseDetailImage: exerciseDetailImage ?? exerciseImage,
        youtubeLink: youtubeLink ?? exerciseYoutubeLink,
        notes: notes ?? exerciseNotes,
      );

  File? get imageFile => profilesImageFile;

  String? get image => profilesImage;

  String? get exerciseTitle => exerciseExerciseTitle;

  String? get description => exerciseDescription;

  File? get exerciseDetailImageFile => exerciseImageFile;

  String? get exerciseDetailImage => exerciseImage;

  String? get youtubeLink => exerciseYoutubeLink;

  String? get notes => exerciseNotes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['imageFile'] = profilesImageFile;
    map['image'] = profilesImage;
    map['exerciseTitle'] = exerciseExerciseTitle;
    map['description'] = exerciseDescription;
    map['exerciseImageFile'] = exerciseImageFile;
    map['exerciseImage'] = exerciseImage;
    map['youtubeLink'] = exerciseYoutubeLink;
    map['notes'] = exerciseNotes;

    return map;
  }
}

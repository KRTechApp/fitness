import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/default_response.dart';
import '../model/exercise_model.dart';
import '../utils/file_upload_utils.dart';

class ExerciseProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> memberExerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> myExerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allMyExerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> exerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allExerciseListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> selectedCategoryExercise = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> findMyExerciseList = <QueryDocumentSnapshot>[];
  String lastCreatedBy = "";

  Future<void> getExerciseByUserId(
      {required String currentUserId, bool isRefresh = false, String searchText = ""}) async {
    debugPrint("lastCreatedBy : $lastCreatedBy");
    lastCreatedBy = currentUserId;
    if (isRefresh) {
      myExerciseListItem.clear();
      allExerciseListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot;
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          allExerciseListItem.clear();
          allExerciseListItem.addAll(querySnapshot.docs);
          debugPrint('allExerciseListItem Length ${allExerciseListItem.length}');
        }
        myExerciseListItem.clear();
        for (var listItem in allExerciseListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            myExerciseListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (myExerciseListItem.isEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(keyCreatedBy, isEqualTo: currentUserId)
              .get();
          myExerciseListItem.clear();
          myExerciseListItem.addAll(querySnapshot.docs);
          debugPrint('currentUserId: $currentUserId');
          debugPrint('myExerciseListItem Length ${myExerciseListItem.length}');
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> getSelectedCategory({required List<String> selectedCategoryId}) async {
    selectedCategoryExercise.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableExercise)
        .where(keyCategoryId, whereIn: selectedCategoryId)
        .get();
    debugPrint('Print Id: $keyCategoryId $selectedCategoryId');
    selectedCategoryExercise.addAll(querySnapshot.docs);
    debugPrint('selectedCategoryExercise: ${selectedCategoryExercise.length}');
    notifyListeners();
  }

  Future<void> getCategoryExercise(
      {required String? categoryId, required String createdBy, bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      myExerciseListItem.clear();
      allExerciseListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(keyCategoryId, isEqualTo: categoryId)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          allExerciseListItem.clear();
          allExerciseListItem.addAll(querySnapshot.docs);
          debugPrint('allExerciseListItem Length ${allExerciseListItem.length}');
        }
        myExerciseListItem.clear();
        for (var listItem in allExerciseListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            myExerciseListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (myExerciseListItem.isEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(keyCategoryId, isEqualTo: categoryId)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          myExerciseListItem.clear();
          myExerciseListItem.addAll(querySnapshot.docs);
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> getSearchMyExercise(
      {bool isRefresh = false, required List<String> exerciseIdList, String searchText = ""}) async {
    if (isRefresh) {
      myExerciseListItem.clear();
      allMyExerciseListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allMyExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(FieldPath.documentId, whereIn: exerciseIdList)
              .get();
          if (allMyExerciseListItem.isEmpty) {
            allMyExerciseListItem.addAll(querySnapshot.docs);
          }
        }
        myExerciseListItem.clear();
        for (var listItem in allMyExerciseListItem) {
          if (listItem[keyExerciseTitle] != null &&
              listItem[keyExerciseTitle].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            myExerciseListItem.add(listItem);
          }
        }
      } else {
        if (myExerciseListItem.isEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(tableExercise)
              .where(FieldPath.documentId, whereIn: exerciseIdList)
              .get();
          myExerciseListItem.addAll(querySnapshot.docs);
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> deleteMyExercise({required exerciseId}) async {
    await FirebaseFirestore.instance.collection(tableExercise).doc(exerciseId).delete();
    int index = myExerciseListItem.indexWhere((element) => element.id == exerciseId);

    var profile = myExerciseListItem[index].get(keyProfile);
    var video = myExerciseListItem[index].get(keyExerciseDetailImage);

    await FileUploadUtils().removeSingleFile(url: profile);
    await FileUploadUtils().removeSingleFile(url: video);

    if (index != -1) myExerciseListItem.removeAt(index);

    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.exercise_deleted_sucessfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<DefaultResponse> addExercise(
      {required ExerciseModel exerciseProvider,
      required selectCategory,
      required List<String> selectedCategoryId,
      required String currentUser}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableExercise)
        .where(keyExerciseTitle, isEqualTo: exerciseProvider.exerciseTitle)
        .where(keyCreatedBy, isEqualTo: currentUser)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.exercise_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (exerciseProvider.imageFile != null) {
      profileURL =
          await FileUploadUtils().uploadImage(folderName: folderExerciseImage, fileImage: exerciseProvider.imageFile!);
    }

    String exerciseDetailImage = "";
    if (exerciseProvider.exerciseImageFile != null) {
      exerciseDetailImage = await FileUploadUtils()
          .uploadImage(folderName: folderExerciseImage, fileImage: exerciseProvider.exerciseImageFile!);
    }

    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyExerciseTitle: exerciseProvider.exerciseTitle,
      keyDescription: exerciseProvider.description,
      keyExerciseDetailImage: exerciseDetailImage,
      keyYoutubeLink: exerciseProvider.youtubeLink,
      keyNotes: exerciseProvider.notes,
      keyProfile: profileURL,
      keyCategoryId: selectCategory,
      keyCreatedBy: currentUser,
    };

    await FirebaseFirestore.instance.collection(tableExercise).doc().set(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.exercise_added_successfully;
      if (selectedCategoryId.isNotEmpty) {
        getCategoryExercise(categoryId: selectCategory, createdBy: currentUser, isRefresh: true, searchText: "");
        getSelectedCategory(selectedCategoryId: selectedCategoryId);
      } else {
        getExerciseByUserId(isRefresh: true, currentUserId: currentUser);
      }
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });

    return defaultResponse;
  }

  Future<DefaultResponse> updateExercise(
      {required exerciseId,
      required ExerciseModel exerciseProvider,
      required selectCategory,
      required List<String> selectedCategoryId,
      required String currentUser}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    debugPrint("exerciseId$exerciseId");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableExercise)
        .where(keyExerciseTitle, isEqualTo: exerciseProvider.exerciseTitle)
        .where(keyCreatedBy, isEqualTo: currentUser)
        .get();
    var currentDoc = query.docs.where((element) => element.id == exerciseId);

    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.exercise_already_exist;
      return defaultResponse;
    }
    String profileURL = "";
    if (exerciseProvider.imageFile != null && exerciseProvider.image != null) {
      profileURL = await FileUploadUtils().uploadAndUpdateImage(
          folderName: folderExerciseImage, fileImage: exerciseProvider.imageFile!, oldUrl: exerciseProvider.image!);
    } else if (exerciseProvider.imageFile != null) {
      profileURL =
          await FileUploadUtils().uploadImage(folderName: folderExerciseImage, fileImage: exerciseProvider.imageFile!);
    } else if (exerciseProvider.image != null) {
      profileURL = exerciseProvider.image!;
    }

    String exerciseDetailImage = "";
    if (exerciseProvider.exerciseImageFile != null && exerciseProvider.exerciseImage != null) {
      exerciseDetailImage = await FileUploadUtils().uploadAndUpdateImage(
          folderName: folderExerciseImage,
          fileImage: exerciseProvider.exerciseImageFile!,
          oldUrl: exerciseProvider.exerciseImage!);
    } else if (exerciseProvider.exerciseImageFile != null) {
      exerciseDetailImage = await FileUploadUtils()
          .uploadImage(folderName: folderExerciseImage, fileImage: exerciseProvider.exerciseImageFile!);
    } else if (exerciseProvider.exerciseImage != null) {
      exerciseDetailImage = exerciseProvider.exerciseImage!;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyExerciseTitle: exerciseProvider.exerciseTitle,
      keyDescription: exerciseProvider.description,
      keyExerciseDetailImage: exerciseDetailImage,
      keyYoutubeLink: exerciseProvider.youtubeLink,
      keyNotes: exerciseProvider.notes,
      keyProfile: profileURL,
      keyCategoryId: selectCategory,
      keyCreatedBy: currentUser,
    };

    await FirebaseFirestore.instance.collection(tableExercise).doc(exerciseId).update(bodyMap).whenComplete(() {
      defaultResponse.statusCode = onSuccess;
      defaultResponse.status = true;
      defaultResponse.message = AppLocalizations.of(navigatorKey.currentContext!)!.exercise_updated_successfully;
      getExerciseByUserId(currentUserId: currentUser, isRefresh: true);
      getCategoryExercise(categoryId: selectCategory, createdBy: currentUser, isRefresh: true);
      if (selectedCategoryId.isNotEmpty) {
        getSelectedCategory(selectedCategoryId: selectedCategoryId);
      } else {
        getExerciseByUserId(isRefresh: true, currentUserId: currentUser);
      }
    }).catchError((e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    });

    return defaultResponse;
  }

  Future<void> getMemberMyExercise(
      {required List<String> exerciseIdList, required String createdBy, String searchText = ""}) async {
    memberExerciseListItem.clear();
    for (int i = 0; i < exerciseIdList.length; i++) {
      QueryDocumentSnapshot? documentSnapshot =
          await findExerciseById(createdBy: createdBy, exerciseId: exerciseIdList[i]);
      if (documentSnapshot != null) {
        if (searchText.isNotEmpty) {
          if (documentSnapshot[keyExerciseTitle].toString().toLowerCase().contains(searchText.toLowerCase())) {
            if (!memberExerciseListItem.contains(documentSnapshot)) {
              memberExerciseListItem.add(documentSnapshot);
            }
          }
        } else {
          if (!memberExerciseListItem.contains(documentSnapshot)) {
            memberExerciseListItem.add(documentSnapshot);
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> getMemberMyExerciseCategory(
      {required List<String> exerciseIdList,
      required String createdBy,
      required String categoryId,
      String searchText = ""}) async {
    memberExerciseListItem.clear();
    for (int i = 0; i < exerciseIdList.length; i++) {
      QueryDocumentSnapshot? documentSnapshot =
          await findExerciseById(createdBy: createdBy, exerciseId: exerciseIdList[i]);
      if (documentSnapshot != null && (documentSnapshot.get(keyCategoryId) == categoryId)) {
        if (searchText.isNotEmpty) {
          if (documentSnapshot[keyExerciseTitle].toString().toLowerCase().contains(searchText.toLowerCase())) {
            if (!memberExerciseListItem.contains(documentSnapshot)) {
              memberExerciseListItem.add(documentSnapshot);
            }
          }
        } else {
          if (!memberExerciseListItem.contains(documentSnapshot)) {
            memberExerciseListItem.add(documentSnapshot);
          }
        }
      }
    }
    notifyListeners();
  }

  Future<QueryDocumentSnapshot?> findExerciseById({required String exerciseId, required String createdBy}) async {
    if (exerciseId.isEmpty) {
      return null;
    }

    if (myExerciseListItem.isEmpty || lastCreatedBy != createdBy) {
      await getExerciseByUserId(isRefresh: true, currentUserId: createdBy);
      debugPrint("lastCreatedBy : $lastCreatedBy");
      lastCreatedBy = createdBy;
    }
    var exerciseData = myExerciseListItem.where((element) => element.id == exerciseId);
    debugPrint("myExerciseListItem :${myExerciseListItem.length}");
    debugPrint("exerciseData :${exerciseData.length}");

    return exerciseData.isNotEmpty ? exerciseData.first : null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/model/default_response.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NutritionProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> nutritionListItem = <QueryDocumentSnapshot>[];
  List<QueryDocumentSnapshot> allNutritionListItem = <QueryDocumentSnapshot>[];

  Future<DefaultResponse> addNutrition(
      {required String nutritionName,
      required String nutritionDetail,
      required List<String> memberList,
      required int startDate,
      required int endDate,
      required String breakFast,
      required String midMorningSnacks,
      required String lunch,
      required String afternoonSnacks,
      required String dinner,
      required selectedDays,
      required String createdBy}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableNutrition)
        .where(keyNutritionName, isEqualTo: nutritionName)
        .get();
    if (query.docs.isNotEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message =
          AppLocalizations.of(navigatorKey.currentContext!)!
              .nutrition_already_exist;
      return defaultResponse;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyNutritionName: nutritionName,
      keyNutritionDetail: nutritionDetail,
      keySelectedMember: memberList,
      keyStartDate: startDate,
      keyEndDate: endDate,
      keyBreakFast: breakFast,
      keyMidMorningSnacks: midMorningSnacks,
      keyLunch: lunch,
      keyAfternoonSnacks: afternoonSnacks,
      keyDinner: dinner,
      keyCreatedBy: createdBy,
      keySelectedDays: selectedDays
    };

    await FirebaseFirestore.instance
        .collection(tableNutrition)
        .add(bodyMap)
        .whenComplete(
      () async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message =
            AppLocalizations.of(navigatorKey.currentContext!)!
                .nutrition_added_successfully;
        getNutritionByUser(createdBy: createdBy, isRefresh: true);
      },
    ).catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<DefaultResponse> updateNutrition(
      {required String nutritionName,
      required String nutritionDetail,
      required List<String> memberList,
      required int startDate,
      required int endDate,
      required String breakFast,
      required String midMorningSnacks,
      required String lunch,
      required String afternoonSnacks,
      required String dinner,
      required selectedDays,
      required String createdBy,
      required String nutritionId}) async {
    DefaultResponse defaultResponse = DefaultResponse();

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tableNutrition)
        .where(keyNutritionName, isEqualTo: nutritionName)
        .get();
    var currentDoc = query.docs.where((element) => element.id == nutritionId);
    /*debugPrint(
        'currentDoc && queryDoc ${currentDoc.first.id} && ${query.docs.first.id}');*/
    if (query.docs.isNotEmpty && currentDoc.isEmpty) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message =
          AppLocalizations.of(navigatorKey.currentContext!)!
              .nutrition_already_exist;
      return defaultResponse;
    }
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyNutritionName: nutritionName,
      keyNutritionDetail: nutritionDetail,
      keySelectedMember: memberList,
      keyStartDate: startDate,
      keyEndDate: endDate,
      keyBreakFast: breakFast,
      keyMidMorningSnacks: midMorningSnacks,
      keyLunch: lunch,
      keyAfternoonSnacks: afternoonSnacks,
      keyDinner: dinner,
      keyCreatedBy: createdBy,
      keySelectedDays: selectedDays
    };

    await FirebaseFirestore.instance
        .collection(tableNutrition)
        .doc(nutritionId)
        .update(bodyMap)
        .whenComplete(
      () async {
        defaultResponse.statusCode = onSuccess;
        defaultResponse.status = true;
        defaultResponse.message =
            AppLocalizations.of(navigatorKey.currentContext!)!
                .nutrition_update_successfully;
        getNutritionByUser(createdBy: createdBy, isRefresh: true);
      },
    ).catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<void> getNutritionByUser(
      {required createdBy,
      bool isRefresh = false,
      String searchText = ""}) async {
    if (isRefresh) {
      allNutritionListItem.clear();
      nutritionListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allNutritionListItem.isEmpty) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
          if (allNutritionListItem.isEmpty) {
            allNutritionListItem.addAll(querySnapshot.docs);
          }
        }
        nutritionListItem.clear();
        for (var listItem in allNutritionListItem) {
          if (listItem[keyNutritionName] != null &&
              listItem[keyNutritionName]
                  .trim()
                  .toLowerCase()
                  .contains(searchText.trim().toLowerCase())) {
            nutritionListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (nutritionListItem.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keyCreatedBy, isEqualTo: createdBy)
              .get();
        }
        nutritionListItem.clear();
        nutritionListItem.addAll(querySnapshot.docs);
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

  Future<void> deleteNutrition({required nutritionId}) async {

    await FirebaseFirestore.instance.collection(tableNutrition).doc(nutritionId).delete();
    int index = nutritionListItem.indexWhere((element) => element.id == nutritionId);
    if (index != -1) nutritionListItem.removeAt(index);
    // getTrainerList(isRefresh: true);
    Fluttertoast.showToast(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!.nutrition_deleted_successfully,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  Future<void> getNutritionForSelectedUser({required userId, bool isRefresh = false, String searchText = ""}) async {
    if (isRefresh) {
      nutritionListItem.clear();
      allNutritionListItem.clear();
    }
    try {
      if (searchText.isNotEmpty) {
        if (allNutritionListItem.isEmpty) {
          var querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keySelectedMember, arrayContains: userId)
              .get();
          if (allNutritionListItem.isEmpty) {
            allNutritionListItem.addAll(querySnapshot.docs);
            debugPrint('allClassListItem Size1${querySnapshot.size}');
          }
        }
        nutritionListItem.clear();
        for (var listItem in allNutritionListItem) {
          if (listItem[keyNutritionName] != null &&
              listItem[keyNutritionName].trim().toLowerCase().contains(searchText.trim().toLowerCase())) {
            nutritionListItem.add(listItem);
          }
        }
      } else {
        QuerySnapshot querySnapshot;
        if (nutritionListItem.isNotEmpty) {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keySelectedMember, arrayContains: userId)
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection(tableNutrition)
              .where(keySelectedMember, arrayContains: userId)
              .get();
        }
        nutritionListItem.clear();
        nutritionListItem.addAll(querySnapshot.docs);
        debugPrint('allClassListItem Size2${querySnapshot.size}');
      }
    } catch (e) {
      debugPrint("$e");
    }
    notifyListeners();
  }

}

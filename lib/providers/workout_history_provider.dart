import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../model/default_response.dart';
import '../model/workout_days_model.dart';

class WorkoutHistoryProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> workoutHistoryListItem = [];
  List<QueryDocumentSnapshot> allWorkoutHistoryListItem = [];
  List<QueryDocumentSnapshot> memberWorkoutHistoryList = [];
  List<QueryDocumentSnapshot> memberWorkoutList = [];
  List<QueryDocumentSnapshot> trainerAllWorkout = [];
  List<QueryDocumentSnapshot> trainerAllWorkoutHistory = [];

  Future<DefaultResponse> addWorkoutHistory({
    required String workoutId,
    required String workoutCategoryId,
    required String exerciseId,
    required String createdBy,
    required int createAt,
    required String set,
    required String sec,
    required String reps,
    required String rest,
    required String exerciseTime,
    required String memberTrainerId,
    required String timerStatus,
    required String exerciseProgress,
    required String weight,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keyWorkoutId: workoutId,
      keyCategoryId: workoutCategoryId,
      keyExerciseId: exerciseId,
      keyCreatedAt: createAt,
      keyCreatedBy: createdBy,
      keySet: set,
      keySec: sec,
      keyReps: reps,
      keyRest: rest,
      keyWorkoutWeight: weight,
      keyExerciseTime: exerciseTime,
      keyTimerStatus: timerStatus,
      keyExerciseProgress: exerciseProgress,
      keyMemberTrainerId: memberTrainerId,
    };
    try {
      await FirebaseFirestore.instance.collection(tableWorkoutHistory).add(bodyMap).then((doc) => {
            defaultResponse.statusCode = onSuccess,
            defaultResponse.status = true,
            defaultResponse.message =
                AppLocalizations.of(navigatorKey.currentContext!)!.workout_data_added_successfully,
            defaultResponse.responseData = doc.id
          });
    } catch (e) {
      defaultResponse.statusCode = onFailed;
      defaultResponse.status = false;
      defaultResponse.message = e.toString();
    }
    return defaultResponse;
  }

  Future<QueryDocumentSnapshot?> getWorkoutHistory(
      {required String workoutId, required String exerciseId, required String createBy, required int createAt}) async {
    debugPrint("getWorkoutHistory createAt :$createAt");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkoutHistory)
        .where(keyWorkoutId, isEqualTo: workoutId)
        .where(keyExerciseId, isEqualTo: exerciseId)
        .where(keyCreatedBy, isEqualTo: createBy)
        .where(keyCreatedAt, isEqualTo: createAt)
        .get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
  }

  Future<void> getAllWorkoutHistory({required String createdBy, required String workoutId}) async {
    allWorkoutHistoryListItem.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkoutHistory)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .where(keyWorkoutId, isEqualTo: workoutId)
        .get();
    debugPrint("getExerciseListForProgress createdBy :$createdBy");
    debugPrint("getExerciseListForProgress workoutId :$workoutId");
    debugPrint("getExerciseListForProgress ${querySnapshot.size}");
    allWorkoutHistoryListItem.addAll(querySnapshot.docs);
    notifyListeners();
  }

  Future<DefaultResponse> updateWorkotHistory({
    required String currentDocId,
    required String createdBy,
    required String sec,
    required String set,
    required String reps,
    required String rest,
    required String exerciseTime,
    required String timerStatus,
    required String exerciseProgress,
    required String memberTrainerId,
    required String weight,
  }) async {
    DefaultResponse defaultResponse = DefaultResponse();
    Map<String, dynamic> bodyMap = <String, dynamic>{
      keySet: set,
      keySec: sec,
      keyRest: rest,
      keyReps: reps,
      keyWorkoutWeight: weight,
      keyExerciseTime: exerciseTime,
      keyTimerStatus: timerStatus,
      keyExerciseProgress: exerciseProgress,
      keyMemberTrainerId: memberTrainerId,
    };
    await FirebaseFirestore.instance
        .collection(tableWorkoutHistory)
        .doc(currentDocId)
        .update(bodyMap)
        .whenComplete(
          () => {
            defaultResponse.statusCode = onSuccess,
            defaultResponse.status = true,
            defaultResponse.message =
                AppLocalizations.of(navigatorKey.currentContext!)!.exercise_data_update_successfully,
          },
        )
        .catchError(
      (e) {
        defaultResponse.statusCode = onFailed;
        defaultResponse.status = false;
        defaultResponse.message = e.toString();
      },
    );
    return defaultResponse;
  }

  Future<void> getAllWorkoutHistoryForSeamDay({required String createdBy, required int currentDate}) async {
    memberWorkoutHistoryList.clear();
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(tableWorkoutHistory)
        .where(keyCreatedBy, isEqualTo: createdBy)
        .where(keyCreatedAt, isEqualTo: currentDate)
        .get();
    debugPrint("getAllWorkoutHistoryForSeamDay createdBy :$createdBy");
    debugPrint("getAllWorkoutHistoryForSeamDay currentDate :$currentDate");
    memberWorkoutHistoryList.addAll(querySnapshot.docs);
    debugPrint("getAllWorkoutHistoryForSeamDay Length ${querySnapshot.docs.length}");
    notifyListeners();
  }

  Future<double> getTotalExerciseProgress({required QueryDocumentSnapshot workoutDoc}) async {
    var finalWorkoutProgress = 0.0;
    var totalProgress = 0.0;
    WorkoutDaysModel? workoutDaysModel;
    var selectedValue = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    debugPrint('selectedValue : $selectedValue');
    workoutDaysModel = WorkoutDaysModel.fromJson(
      json.decode(
        workoutDoc[keyWorkoutData],
      ),
    );
    debugPrint("workoutDoc[keyWorkoutData]${workoutDoc[keyWorkoutData]}");
    List<ExerciseDataItem> exerciseDataList = getDayByExercise(day: selectedValue, workoutDaysModel: workoutDaysModel);
    debugPrint('exerciseDataList : ${exerciseDataList.length}');

    for (int i = 0; i < memberWorkoutHistoryList.length; i++) {
      debugPrint('Workout Id : ${memberWorkoutHistoryList[i].get(keyWorkoutId)}');
      debugPrint('Workout Id123 : ${workoutDoc.id}');
      if (memberWorkoutHistoryList[i].get(keyWorkoutId) == workoutDoc.id) {
        totalProgress = totalProgress +
            double.parse(getDocumentValue(
                documentSnapshot: memberWorkoutHistoryList[i], key: keyExerciseProgress, defaultValue: "0.0"));
      }
    }
    debugPrint('totalProgress : ${totalProgress}');
    debugPrint('exerciseDataList.length : ${exerciseDataList.length}');
    finalWorkoutProgress = totalProgress / exerciseDataList.length;
    return finalWorkoutProgress;
  }

  Future<double> getTotalWorkoutTotalExerciseProgress({required String memberId}) async {
    var finalWorkoutProgress = 0.0;
    var totalProgress = 0.0;
    var totalExercise = 0.0;
    for (var tempWorkout in trainerAllWorkout) {
      List<String> memberList = List.castFrom(tempWorkout.get(keySelectedMember));
      if (memberList.contains(memberId)) {
        WorkoutDaysModel? workoutDaysModel;
        var selectedValue = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
        debugPrint('selectedValue : $selectedValue');
        workoutDaysModel = WorkoutDaysModel.fromJson(
          json.decode(
            tempWorkout[keyWorkoutData],
          ),
        );
        debugPrint("getTotalWorkoutTotalExerciseProgress workoutDoc[keyWorkoutData]${tempWorkout[keyWorkoutData]}");
        List<ExerciseDataItem> exerciseDataList =
            getDayByExercise(day: selectedValue, workoutDaysModel: workoutDaysModel);
        totalExercise = exerciseDataList.length + totalExercise;
        debugPrint('getTotalWorkoutTotalExerciseProgress exerciseDataList : ${exerciseDataList.length}');
        memberWorkoutHistoryList.clear();
        for (var memberWorkout in trainerAllWorkoutHistory) {
          if (memberWorkout[keyCreatedBy] == memberId) {
            memberWorkoutHistoryList.add(memberWorkout);
          }
        }
        for (int j = 0; j < memberWorkoutHistoryList.length; j++) {
          debugPrint(
              'getTotalWorkoutTotalExerciseProgress Workout Id : ${memberWorkoutHistoryList[j].get(keyWorkoutId)}');
          debugPrint('getTotalWorkoutTotalExerciseProgress Workout Id123 : ${tempWorkout.id}');
          if (memberWorkoutHistoryList[j].get(keyWorkoutId) == tempWorkout.id) {
            totalProgress = totalProgress +
                double.parse(getDocumentValue(
                    documentSnapshot: memberWorkoutHistoryList[j], key: keyExerciseProgress, defaultValue: "0.0"));
          }
        }
        debugPrint('getTotalWorkoutTotalExerciseProgress totalProgress : ${totalProgress}');
        debugPrint('getTotalWorkoutTotalExerciseProgress exerciseDataList.length : $totalExercise');
        finalWorkoutProgress = totalProgress / totalExercise;
        debugPrint('getTotalWorkoutTotalExerciseProgress finalWorkoutProgress : $finalWorkoutProgress');
      }
    }
    return finalWorkoutProgress;
  }

/*  Future<double> getTotalWorkoutTotalExerciseProgress(
      {required List<QueryDocumentSnapshot> workoutDoc}) async {
    var finalWorkoutProgress = 0.0;
    var totalProgress = 0.0;
    var totalExercise = 0.0;
    for (int i = 0; i < workoutDoc.length; i++) {
      WorkoutDaysModel? workoutDaysModel;
      var selectedValue =
          DateFormat('EEEE').format(DateTime.now()).toLowerCase();
      debugPrint('selectedValue : $selectedValue');
      workoutDaysModel = WorkoutDaysModel.fromJson(
        json.decode(
          workoutDoc[i][keyWorkoutData],
        ),
      );
      debugPrint(
          "getTotalWorkoutTotalExerciseProgress workoutDoc[keyWorkoutData]${workoutDoc[i][keyWorkoutData]}");
      List<ExerciseDataItem> exerciseDataList = getDayByExercise(
          day: selectedValue, workoutDaysModel: workoutDaysModel);
      totalExercise = exerciseDataList.length + totalExercise;
      debugPrint(
          'getTotalWorkoutTotalExerciseProgress exerciseDataList : ${exerciseDataList.length}');
      for (int j = 0; j < memberWorkoutHistoryList.length; j++) {
        debugPrint(
            'getTotalWorkoutTotalExerciseProgress Workout Id : ${memberWorkoutHistoryList[j].get(keyWorkoutId)}');
        debugPrint(
            'getTotalWorkoutTotalExerciseProgress Workout Id123 : ${workoutDoc[i].id}');
        if (memberWorkoutHistoryList[j].get(keyWorkoutId) == workoutDoc[i].id) {
          totalProgress = totalProgress +
              double.parse(getDocumentValue(
                  documentSnapshot: memberWorkoutHistoryList[j],
                  key: keyExerciseProgress,
                  defaultValue: "0.0"));
        }
      }
      debugPrint(
          'getTotalWorkoutTotalExerciseProgress totalProgress : ${totalProgress}');
      debugPrint(
          'getTotalWorkoutTotalExerciseProgress exerciseDataList.length : $totalExercise');
      finalWorkoutProgress = totalProgress / totalExercise;
      debugPrint(
          'getTotalWorkoutTotalExerciseProgress finalWorkoutProgress : $finalWorkoutProgress');
    }
    return finalWorkoutProgress;
  }*/

  Future<void> getTrainerAllWorkout({bool isRefresh = false, required String trainerId}) async {
    if (isRefresh) {
      trainerAllWorkout.clear();
    }
    try {
      QuerySnapshot querySnapshot;
      if (trainerAllWorkout.isEmpty) {
        querySnapshot =
            await FirebaseFirestore.instance.collection(tableWorkout).where(keyCreatedBy, isEqualTo: trainerId).get();
        trainerAllWorkout.addAll(querySnapshot.docs);
      }
      debugPrint('trainerAllWorkout: ${trainerAllWorkout.length}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getAllMemberWorkoutHistory({bool isRefresh = false, required String trainerId}) async {
    if (isRefresh) {
      trainerAllWorkoutHistory.clear();
    }
    try {
      QuerySnapshot querySnapshot;
      if (trainerAllWorkoutHistory.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(tableWorkoutHistory)
            .where(keyMemberTrainerId, isEqualTo: trainerId)
            .where(keyCreatedAt, isEqualTo: getCurrentDateOnly())
            .get();
        trainerAllWorkoutHistory.addAll(querySnapshot.docs);
      }
      debugPrint('trainerAllWorkoutHistory : ${trainerAllWorkoutHistory.length}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

/*Future<double> getMemberWorkout({required String memberId}) async {
    var finalWorkoutData = 0.0;
    debugPrint('memberId $memberId');
    memberWorkoutList.clear();
    for (var tempWorkout in workoutListItem) {
      List<String> memberList = List.castFrom(tempWorkout.get(keyCreatedBy));
      if (memberList.contains(memberId)) {
        memberWorkoutList.add(tempWorkout);
      }
    }
    finalWorkoutData =  getTotalWorkoutTotalExerciseProgress(
        workoutDoc: memberWorkoutList, memberId: memberId);
    debugPrint('finalWorkoutData : $finalWorkoutData');
    return finalWorkoutData;
  }*/
}

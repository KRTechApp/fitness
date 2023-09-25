import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../custom_widgets/workout_details_exercise_item_view.dart';
import '../model/workout_days_model.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_category_provider.dart';

class WorkoutDetailExerciseScreen extends StatefulWidget {
  final DocumentSnapshot queryDocumentSnapshot;
  final String workoutCreatedBy;
  final String userRole;
  final String currentLanguage;
  final ShowProgressDialog showProgressDialog;

  const WorkoutDetailExerciseScreen({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.userRole,
    required this.workoutCreatedBy,
    required this.showProgressDialog, required this.currentLanguage,
  }) : super(key: key);

  @override
  State<WorkoutDetailExerciseScreen> createState() => _WorkoutDetailExerciseScreenState();
}

class _WorkoutDetailExerciseScreenState extends State<WorkoutDetailExerciseScreen> {
  List<ExerciseDataItem> exerciseDataList = [];
  late WorkoutDaysModel workoutDaysModel;
  List<String> selectExerciseIdList = [UniqueKey().toString()];
  late ExerciseProvider exerciseProvider;
  late WorkoutProvider workoutProvider;
  late WorkoutCategoryProvider workoutCategoryProvider;

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        workoutDaysModel = WorkoutDaysModel.fromJson(
          json.decode(
            widget.queryDocumentSnapshot[keyWorkoutData],
          ),
        );
        getExercise();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    debugPrint("WorkoutDetailExerciseScreen build");
    return SizedBox(
      width: width,
      height: height,
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: exerciseDataList.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: exerciseDataList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return WorkoutDetailsExerciseItemView(
                    exerciseDataList: exerciseDataList[index],
                    workoutCreatedBy: widget.workoutCreatedBy,
                    currentLanguage:  widget.currentLanguage,
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: ColorCode.tabDivider,
                      maxRadius: 45,
                      child: Image.asset('assets/images/empty_box.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                      child: Text(
                        AppLocalizations.of(context)!.you_do_not_have_any_exercise,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: ColorCode.listSubTitle,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
    /*SizedBox(
        width: width,
        height: height,
        child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child:exerciseDataList.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 80),
                  itemCount: exerciseDataList.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // final QueryDocumentSnapshot documentSnapshot = exerciseData.exerciseListItem[index];
                    debugPrint('exerciseId: ${exerciseDataList[index].id ?? ""} createdBy:${ widget.workoutCreatedBy}');
                    return FutureBuilder(
                        future: exerciseProvider.findExerciseById(
                            exerciseId: exerciseDataList[index].id ?? "", createdBy: widget.workoutCreatedBy),
                        builder: (BuildContext context, AsyncSnapshot<QueryDocumentSnapshot?> snapshot) {
                          if (snapshot.hasData) {
                            final QueryDocumentSnapshot querydocumentsnapshot = snapshot.data as QueryDocumentSnapshot;
                            return Padding(
                              padding: const EdgeInsets.only(right: 15, left: 15),
                              child: Column(
                                children: [
                                  InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            enableDrag: false,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(20.0),
                                              ),
                                            ),
                                            builder: (context) => MemberWorkoutDetails(exerciseDataModel: exerciseDataList[index],queryDocumentSnapshot: querydocumentsnapshot),
                                          );
                                        },
                                    child: CustomCard(
                                      blurRadius: 5,
                                      radius: 15,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: FadeInImage(
                                                fit: BoxFit.cover,
                                                width: 50,
                                                height: 50,
                                                image: customPlaceHolderImageProvider(url: querydocumentsnapshot[keyProfile],),
                                                placeholderFit: BoxFit.fitWidth,
                                                placeholder: AssetImage('assets/images/ic_App_Logo.png'),
                                                imageErrorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                      width: 50, height: 50, 'assets/images/ic_App_Logo.png');
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.38,
                                            child: Text(
                                              querydocumentsnapshot[keyExerciseTitle] ?? "",
                                              maxLines: 1,
                                              style: GymStyle.listTitle,
                                            ),
                                          ),
                                          Spacer(),
                                          if(widget.userRole == userRoleTrainer)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 15),
                                            child: PopupMenuButton(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0),),),
                                                onSelected: (selection) async {
                                                  switch (selection) {
                                                    case 0:
                                                      removeExercise(exerciseId: querydocumentsnapshot.id);
                                                      break;
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                      PopupMenuItem(
                                                          value: 0,
                                                          child: Text(AppLocalizations.of(context)!.delete.firstCapitalize(),
                                                              style: GymStyle.popupboxdelate),),
                                                    ],
                                                child: Container(
                                                  height: 35,
                                                  width: 30,
                                                  alignment: Alignment.center,
                                                  child: Icon(Icons.more_vert, color: ColorCode.grayLight),
                                                ),),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.012,
                                  ),
                                ],
                              ),
                            );
                          }
                          return Text('');
                        },);
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: ColorCode.tabDivider,
                        maxRadius: 45,
                        child: Image.asset('assets/images/empty_box.png'),
                      ),
                       Padding(
                        padding: EdgeInsets.only(left: 17.0, right: 17, top: 15),
                        child: Text(
                          AppLocalizations.of(context)!.you_do_not_have_any_exercise,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: ColorCode.listSubTitle,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),)*/
  }

  Future<void> getExercise() async {
    widget.showProgressDialog.show();

    exerciseDataList.clear();
    exerciseDataList.addAll(
      workoutDaysModel.exerciseDataList ?? [],
    );
    debugPrint('getExercise Size : ${exerciseDataList.length}');
    if (exerciseDataList.isNotEmpty) {
      await exerciseProvider.getExerciseByUserId(isRefresh: true, currentUserId: widget.workoutCreatedBy);
      await workoutCategoryProvider.getMyWorkoutCategory(isRefresh: true, createdBy: widget.workoutCreatedBy);
    }
    if (mounted) {
      setState(
        () {},
      );
    } else {
      debugPrint("getExercise not refreshing");
    }
    widget.showProgressDialog.hide();
  }

  Future<void> removeExercise({required String exerciseId}) async {
    debugPrint('exerciseId $exerciseId');
    if (workoutDaysModel.exerciseDataList != null && workoutDaysModel.exerciseDataList!.isNotEmpty) {
      workoutDaysModel.exerciseDataList!.removeWhere((element) => element.exerciseId == exerciseId);
    }
    await workoutProvider.updateWorkoutData(
      workoutId: widget.queryDocumentSnapshot.id,
      workoutData: jsonEncode(workoutDaysModel),
    );
    DocumentSnapshot? querySnapshot =
        await workoutProvider.getSingleWorkout(workoutId: widget.queryDocumentSnapshot.id);
    if (querySnapshot != null) {
      workoutDaysModel = WorkoutDaysModel.fromJson(
        json.decode(
          querySnapshot[keyWorkoutData],
        ),
      );
    }
    getExercise();
  }

  Future<void> _pullRefresh() async {
    debugPrint("_pullRefresh");
    getExercise();
  }

  void onExerciseSelect(String item) {
    setState(
      () {
        selectExerciseIdList.remove(item);
      },
    );
  }
}

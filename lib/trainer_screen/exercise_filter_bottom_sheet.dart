// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../Utils/color_code.dart';
import '../custom_widgets/custom_card.dart';
import '../model/workout_days_model.dart';
import '../providers/workout_category_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class ExerciseFilterBottomSheet extends StatefulWidget {
  final String userId;
  final String userRole;
  final String userCreatedBy;
  String categoryId;

  ExerciseFilterBottomSheet({super.key, required this.userId, required this.userRole, required this.categoryId, required this.userCreatedBy});

  @override
  State<ExerciseFilterBottomSheet> createState() => _ExerciseFilterBottomSheetState();
}

class _ExerciseFilterBottomSheetState extends State<ExerciseFilterBottomSheet> {
  late WorkoutCategoryProvider workoutCategoryProvider;
  late ShowProgressDialog showProgressDialog;
  late WorkoutProvider workoutProvider;
  List<String> workoutCategoryIdList = [];

  @override
  void initState() {
    super.initState();
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.userRole == userRoleMember) {
        await workoutProvider.getWorkoutForSelectedMember(selectedMemberId: widget.userId);
        List<WorkoutDaysModel> workoutDaysModelList = [];
        for (int i = 0; i < workoutProvider.selectedMemberWorkout.length; i++) {
          workoutDaysModelList.add(
            WorkoutDaysModel.fromJson(
              json.decode(
                workoutProvider.selectedMemberWorkout[i][keyWorkoutData],
              ),
            ),
          );
        }
        workoutCategoryIdList.clear();
        for (int i = 0; i < workoutDaysModelList.length; i++) {
          workoutCategoryIdList.addAll(
            getWorkoutCategoryIdList(
              workoutDaysModelList[i],
            ),
          );
        }
        debugPrint('exerciseIdList 123: ${workoutCategoryIdList.length}');
        await workoutCategoryProvider.getSearchMyWorkoutCategory(
            isRefresh: true, workoutCategoryIdList: workoutCategoryIdList, createdBy: widget.userCreatedBy);
      }else{
        await workoutCategoryProvider.getWorkoutCategoryList(isRefresh: true, createdBy: widget.userId);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height * 0.75,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 15, top: 15),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/arrow-left.svg'),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    AppLocalizations.of(context)!.filter,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 35,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(
                          () {
                            widget.categoryId = "all";
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.mainColor,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.reset,
                        style: GymStyle.resetButton,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                height: height - 275,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: customCard(
                          blurRadius: 5,
                          radius: 15,
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: 70,
                                height: 80,
                                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Text(AppLocalizations.of(context)!.all,
                                    maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Radio(
                                  activeColor: ColorCode.mainColor,
                                  value: "all",
                                  groupValue: widget.categoryId,
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        widget.categoryId = "all";
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      widget.userRole == userRoleMember
                          ? Consumer<WorkoutCategoryProvider>(
                              builder: (context, workoutCategoryData, child) => workoutCategoryProvider
                                      .myWorkoutCategoryItem.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(top: 10, bottom: 70),
                                      itemCount: workoutCategoryData.myWorkoutCategoryItem.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final QueryDocumentSnapshot documentSnapshot =
                                            workoutCategoryData.myWorkoutCategoryItem[index];
                                        return Column(
                                          children: [
                                            customCard(
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
                                                        image: customImageProvider(
                                                          url: documentSnapshot[keyProfile],
                                                        ),
                                                        placeholderFit: BoxFit.fitWidth,
                                                        placeholder: customImageProvider(),
                                                        imageErrorBuilder: (context, error, stackTrace) {
                                                          return getPlaceHolder();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.5,
                                                    child: Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                        maxLines: 1,
                                                        style: GymStyle.listTitle,
                                                        overflow: TextOverflow.ellipsis),
                                                  ),
                                                  const Spacer(),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Radio(
                                                      activeColor: ColorCode.mainColor,
                                                      value: documentSnapshot.id,
                                                      groupValue: widget.categoryId,
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            widget.categoryId = value.toString();
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * 0.015,
                                            ),
                                          ],
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
                                              AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
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
                            )
                          : Consumer<WorkoutCategoryProvider>(
                              builder: (context, workoutCategoryData, child) => workoutCategoryProvider
                                      .workoutCategoryItem.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(top: 10, bottom: 70),
                                      itemCount: workoutCategoryProvider.workoutCategoryItem.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final QueryDocumentSnapshot documentSnapshot =
                                            workoutCategoryData.workoutCategoryItem[index];
                                        return Column(
                                          children: [
                                            customCard(
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
                                                        image: customImageProvider(
                                                          url: documentSnapshot[keyProfile],
                                                        ),
                                                        placeholderFit: BoxFit.fitWidth,
                                                        placeholder: customImageProvider(),
                                                        imageErrorBuilder: (context, error, stackTrace) {
                                                          return getPlaceHolder();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Text(documentSnapshot[keyWorkoutCategoryTitle] ?? "",
                                                      maxLines: 1,
                                                      style: GymStyle.listTitle,
                                                      overflow: TextOverflow.ellipsis),
                                                  const Spacer(),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Radio(
                                                      activeColor: ColorCode.mainColor,
                                                      value: documentSnapshot.id,
                                                      groupValue: widget.categoryId,
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            widget.categoryId = value.toString();
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * 0.015,
                                            ),
                                          ],
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
                                              AppLocalizations.of(context)!.you_do_not_have_any_workout_category,
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
                    ],
                  ),
                )),
          ]),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: SizedBox(
            height: height * 0.08,
            width: width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, widget.categoryId);
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: ColorCode.mainColor,
              ),
              child: Text(AppLocalizations.of(context)!.done, style: GymStyle.buttonTextStyle),
            ),
          ),
        ),
      ],
    );
  }

  List<String> getWorkoutCategoryIdList(WorkoutDaysModel workoutDaysModel) {
    List<String> tempWorkoutCategoryList = [];
    if (workoutDaysModel.exerciseDataList != null) {
      for (int i = 0; i < workoutDaysModel.exerciseDataList!.length; i++) {
        tempWorkoutCategoryList.add(workoutDaysModel.exerciseDataList![i].categoryId ?? "");
      }
    }
    debugPrint('getWorkoutCategoryIdList : ${tempWorkoutCategoryList.length}');
    return tempWorkoutCategoryList;
  }
}

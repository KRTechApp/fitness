import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../model/workout_days_model.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_category_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import 'custom_card.dart';
import 'exercise_details_bottom_sheet.dart';

class WorkoutDetailsExerciseItemView extends StatefulWidget {
  final ExerciseDataItem exerciseDataList;
  final String workoutCreatedBy;
  final String currentLanguage;

  const WorkoutDetailsExerciseItemView({Key? key, required this.exerciseDataList, required this.workoutCreatedBy, required this.currentLanguage})
      : super(key: key);

  @override
  State<WorkoutDetailsExerciseItemView> createState() => _WorkoutDetailsExerciseItemViewState();
}

class _WorkoutDetailsExerciseItemViewState extends State<WorkoutDetailsExerciseItemView> {
  late ExerciseProvider exerciseProvider;
  late WorkoutProvider workoutProvider;
  late WorkoutCategoryProvider workoutCategoryProvider;
  var setController = TextEditingController();
  var repsController = TextEditingController();
  var secController = TextEditingController();
  var restController = TextEditingController();

  @override
  void initState() {
    super.initState();
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    setController.text = widget.exerciseDataList.exerciseDataSet ?? "";
    repsController.text = widget.exerciseDataList.exerciseDataReps ?? "";
    secController.text = widget.exerciseDataList.exerciseDataSec ?? "";
    restController.text = widget.exerciseDataList.exerciseDataRest ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var dayWidth = (width / 7) - 7.1;

    return SizedBox(
      width: width,
      child: FutureBuilder(
        future: exerciseProvider.findExerciseById(
            exerciseId: widget.exerciseDataList.exerciseId ?? "", createdBy: widget.workoutCreatedBy),
        builder: (BuildContext context, AsyncSnapshot<QueryDocumentSnapshot?> snapshot) {
          if (snapshot.hasData) {
            final QueryDocumentSnapshot queryDocSnapshot = snapshot.data as QueryDocumentSnapshot;
            debugPrint("WorkoutDetailsExerciseItemView queryDocSnapshot ${queryDocSnapshot.data()}");
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  enableDrag: true,
                  useRootNavigator: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  builder: (context) =>
                      ExerciseDetailsBottomSheet(exerciseDataModel: null, queryDocumentSnapshot: queryDocSnapshot),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: customCard(
                  blurRadius: 5,
                  radius: 15,
                  child: SizedBox(
                    width: width - 38,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 14, 15),
                          child: Row(
                            children: [
                              FutureBuilder(
                                future: workoutCategoryProvider.findWorkoutById(
                                  createdBy: widget.workoutCreatedBy,
                                  categoryId: queryDocSnapshot.get(keyCategoryId),
                                ),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
                                  if (snapshot.hasData) {
                                    final DocumentSnapshot querydocumentsnapshot = snapshot.data as DocumentSnapshot;
                                    return Container(
                                      height: 40,
                                      width: width * 0.38,
                                      padding: const EdgeInsets.symmetric(horizontal: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: ColorCode.backgroundColor, width: 1),
                                      ),
                                      child: Center(
                                        child: customMarquee(
                                            width: width * 0.38,
                                            height: 25,
                                            text: querydocumentsnapshot[keyWorkoutCategoryTitle] ?? "",
                                            textStyle: GymStyle.headerColor1),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                              const Spacer(),
                              Container(
                                height: 40,
                                width: width * 0.38,
                                padding: const EdgeInsets.symmetric(horizontal: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: ColorCode.backgroundColor, width: 1),
                                ),
                                child: Center(
                                  child: customMarquee(
                                      width: width * 0.38,
                                      height: 25,
                                      text: queryDocSnapshot[keyExerciseTitle] ?? "",
                                      textStyle: GymStyle.headerColor1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              SizedBox(
                                width: width * 0.179,
                                height: height * 0.05,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: setController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context)!.set,
                                    labelStyle: GymStyle.smalltTextinput,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorCode.tabBarBoldText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 11,
                              ),
                              SizedBox(
                                width: width * 0.179,
                                height: height * 0.05,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: repsController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context)!.reps,
                                    labelStyle: GymStyle.smalltTextinput,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorCode.tabBarBoldText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 11,
                              ),
                              SizedBox(
                                width: width * 0.179,
                                height: height * 0.05,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: secController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context)!.sec,
                                    labelStyle: GymStyle.smalltTextinput,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorCode.tabBarBoldText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 11,
                              ),
                              SizedBox(
                                width: width * 0.179,
                                height: height * 0.05,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: restController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context)!.rest,
                                    labelStyle: GymStyle.smalltTextinput,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorCode.tabBarBoldText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Divider(height: 1, thickness: 2),
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: dayWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: checkRtl(currentLanguage: widget.currentLanguage) ? const Radius.circular(15) : const Radius.circular(0),
                                  bottomLeft: checkRtl(currentLanguage:  widget.currentLanguage) ? const Radius.circular(0) : const Radius.circular(15),
                                ),
                                color: widget.exerciseDataList.dayList!.contains(daySunday)
                                    ? ColorCode.mainColor
                                    : ColorCode.mainColor1,
                              ),
                              child: Center(
                                  child: Text(
                                'SU',
                                style: widget.exerciseDataList.dayList!.contains(daySunday)
                                    ? GymStyle.dayNameEnable
                                    : GymStyle.dayNameDisable,
                              )),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseDataList.dayList!.contains(dayMonday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('MO',
                                      style: widget.exerciseDataList.dayList!.contains(dayMonday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: width * 0.122,
                              color: widget.exerciseDataList.dayList!.contains(dayTuesday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('TU',
                                      style: widget.exerciseDataList.dayList!.contains(dayTuesday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseDataList.dayList!.contains(dayWednesday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('WE',
                                      style: widget.exerciseDataList.dayList!.contains(dayWednesday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseDataList.dayList!.contains(dayThursday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('TH',
                                      style: widget.exerciseDataList.dayList!.contains(dayThursday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseDataList.dayList!.contains(dayFriday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('FR',
                                      style: widget.exerciseDataList.dayList!.contains(dayFriday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 40,
                              width: dayWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: checkRtl(currentLanguage: widget.currentLanguage) ? const Radius.circular(0) : const Radius.circular(15),
                                  bottomLeft: checkRtl(currentLanguage:  widget.currentLanguage) ? const Radius.circular(15) : const Radius.circular(0),),
                                color: widget.exerciseDataList.dayList!.contains(daySaturday)
                                    ? ColorCode.mainColor
                                    : ColorCode.mainColor1,
                              ),
                              child: Center(
                                  child: Text('SA',
                                      style: widget.exerciseDataList.dayList!.contains(daySaturday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Text('');
        },
      ),
    );
  }
}

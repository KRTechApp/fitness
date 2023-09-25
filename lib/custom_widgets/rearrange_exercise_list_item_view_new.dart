import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Utils/color_code.dart';
import '../model/workout_days_model.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_category_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';
import 'workout_category_bottom_sheet.dart';
import 'workout_exercise_bottom_sheet.dart';

class RearrangeExerciseListItemViewNew extends StatefulWidget {
  final ExerciseDataItem exerciseItem;
  final String userId;
  final int index;
  final Function(ExerciseDataItem) onExerciseSelect;
  final Function(int, String, String, String, String, String, String, List<String>) onExerciseItemUpdate;

  const RearrangeExerciseListItemViewNew(
      {required this.exerciseItem,
      Key? key,
      required this.userId,
      required this.onExerciseSelect,
      required this.onExerciseItemUpdate,
      required this.index})
      : super(key: key);

  @override
  State<RearrangeExerciseListItemViewNew> createState() => _RearrangeExerciseListItemViewNewState();
}

class _RearrangeExerciseListItemViewNewState extends State<RearrangeExerciseListItemViewNew> {
  var setController = TextEditingController();
  var repsController = TextEditingController();
  var secController = TextEditingController();
  var restController = TextEditingController();
  String workoutCategoryId = "";
  String exerciseId = "";
  late WorkoutCategoryProvider workoutCategoryProvider;
  late ExerciseProvider exerciseProvider;

  @override
  void initState() {
    super.initState();
    workoutCategoryProvider = Provider.of<WorkoutCategoryProvider>(context, listen: false);
    exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
        workoutCategoryId = widget.exerciseItem.categoryId ?? "";
        exerciseId = widget.exerciseItem.exerciseId ?? "";
        setController.text = widget.exerciseItem.set ?? "";
        repsController.text = widget.exerciseItem.reps ?? "";
        secController.text = widget.exerciseItem.sec ?? "";
        restController.text = widget.exerciseItem.rest ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var dayWidth = (width / 7) - 7.1;

    return Stack(
      key: ValueKey(widget.exerciseItem),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCard(
            blurRadius: 5,
            radius: 15,
            child: Row(
              children: [
                SizedBox(
                  // height: 130,
                  width: width - 38,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 14, 15),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/rearrange.svg',
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () async {
                                hideKeyboard();
                                String? tempWorkoutId = await showModalBottomSheet(
                                  context: context,
                                  enableDrag: false,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) => WorkoutCategoryBottomSheet(
                                      userId: widget.userId, selectedCategory: workoutCategoryId),
                                );
                                if (tempWorkoutId != null) {
                                  setState(() {
                                    workoutCategoryId = tempWorkoutId;
                                    exerciseId = "";
                                    widget.onExerciseItemUpdate(
                                        widget.index,
                                        workoutCategoryId,
                                        exerciseId,
                                        setController.text.trim(),
                                        repsController.text.trim(),
                                        secController.text.trim(),
                                        restController.text.trim(),
                                        widget.exerciseItem.dayList!);
                                  });
                                }
                              },
                              child: Container(
                                  height: 40,
                                  width: width * 0.34,
                                  padding: const EdgeInsets.symmetric(horizontal: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: ColorCode.backgroundColor, width: 1),
                                  ),
                                  child: Center(
                                      child: Row(
                                    children: [
                                      FutureBuilder(
                                        future: workoutCategoryProvider.findWorkoutById(
                                          createdBy: widget.userId,
                                          categoryId: workoutCategoryId,
                                        ),
                                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
                                          if (snapshot.hasData) {
                                            final DocumentSnapshot documentSnapshot = snapshot.data as DocumentSnapshot;
                                            return customMarquee(
                                                text: documentSnapshot[keyWorkoutCategoryTitle],
                                                textStyle: GymStyle.titleLightDark,
                                                width: 21.w,
                                                height: 25);
                                          }
                                          return Text('Category', style: GymStyle.titleLightDark);
                                        },
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.expand_more_rounded, color: Colors.black, size: 30),
                                    ],
                                  ))),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (workoutCategoryId.isEmpty) {
                                  return;
                                }
                                hideKeyboard();
                                String? tempExerciseId = await showModalBottomSheet(
                                  context: context,
                                  enableDrag: false,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) => WorkoutExerciseBottomSheet(
                                    userId: widget.userId,
                                    workoutCategoryId: workoutCategoryId,
                                    exerciseId: exerciseId,
                                  ),
                                );
                                debugPrint("tempExerciseId : $tempExerciseId");
                                if (tempExerciseId != null) {
                                  setState(() {
                                    exerciseId = tempExerciseId;
                                    widget.onExerciseItemUpdate(
                                        widget.index,
                                        workoutCategoryId,
                                        exerciseId,
                                        setController.text.trim(),
                                        repsController.text.trim(),
                                        secController.text.trim(),
                                        restController.text.trim(),
                                        widget.exerciseItem.dayList!);
                                  });
                                }
                              },
                              child: Container(
                                  height: 40,
                                  width: width * 0.34,
                                  padding: const EdgeInsets.symmetric(horizontal: 7),
                                  decoration: BoxDecoration(
                                    color: workoutCategoryId.isEmpty ? ColorCode.tabDivider : ColorCode.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: ColorCode.backgroundColor, width: 1),
                                  ),
                                  child: Center(
                                      child: Row(
                                    children: [
                                      FutureBuilder(
                                        future: exerciseProvider.findExerciseById(
                                            exerciseId: exerciseId, createdBy: widget.userId),
                                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
                                          if (snapshot.hasData) {
                                            final DocumentSnapshot documentSnapshot = snapshot.data as DocumentSnapshot;
                                            return customMarquee(
                                                text: documentSnapshot[keyExerciseTitle],
                                                textStyle: GymStyle.titleLightDark,
                                                width: 21.w,
                                                height: 25);
                                          }
                                          return Text('Exercise', style: GymStyle.titleLightDark);
                                        },
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.expand_more_rounded, color: Colors.black, size: 30),
                                    ],
                                  ))),
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
                                enableInteractiveSelection: false,
                                maxLength: 3,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  widget.onExerciseItemUpdate(
                                      widget.index,
                                      workoutCategoryId,
                                      exerciseId,
                                      setController.text.trim(),
                                      repsController.text.trim(),
                                      secController.text.trim(),
                                      restController.text.trim(),
                                      widget.exerciseItem.dayList!);
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!.set,
                                  labelStyle: GymStyle.smalltTextinput,
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
                                enableInteractiveSelection: false,
                                maxLength: 3,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!.reps,
                                  labelStyle: GymStyle.smalltTextinput,
                                ),
                                onChanged: (value) {
                                  widget.onExerciseItemUpdate(
                                      widget.index,
                                      workoutCategoryId,
                                      exerciseId,
                                      setController.text.trim(),
                                      repsController.text.trim(),
                                      secController.text.trim(),
                                      restController.text.trim(),
                                      widget.exerciseItem.dayList!);
                                },
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
                                enableInteractiveSelection: false,
                                maxLength: 3,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!.sec,
                                  labelStyle: GymStyle.smalltTextinput,
                                ),
                                onChanged: (value) {
                                  widget.onExerciseItemUpdate(
                                      widget.index,
                                      workoutCategoryId,
                                      exerciseId,
                                      setController.text.trim(),
                                      repsController.text.trim(),
                                      secController.text.trim(),
                                      restController.text.trim(),
                                      widget.exerciseItem.dayList!);
                                },
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
                                enableInteractiveSelection: false,
                                maxLength: 3,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!.rest,
                                  labelStyle: GymStyle.smalltTextinput,
                                ),
                                onChanged: (value) {
                                  widget.onExerciseItemUpdate(
                                      widget.index,
                                      workoutCategoryId,
                                      exerciseId,
                                      setController.text.trim(),
                                      repsController.text.trim(),
                                      secController.text.trim(),
                                      restController.text.trim(),
                                      widget.exerciseItem.dayList!);
                                },
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
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(daySunday)) {
                                widget.exerciseItem.dayList!.add(daySunday);
                              } else {
                                widget.exerciseItem.dayList!.remove(daySunday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15)),
                                color: widget.exerciseItem.dayList!.contains(daySunday)
                                    ? ColorCode.mainColor
                                    : ColorCode.mainColor1,
                              ),
                              child: Center(
                                  child: Text(
                                'SU',
                                style: widget.exerciseItem.dayList!.contains(daySunday)
                                    ? GymStyle.dayNameEnable
                                    : GymStyle.dayNameDisable,
                              )),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(dayMonday)) {
                                widget.exerciseItem.dayList!.add(dayMonday);
                              } else {
                                widget.exerciseItem.dayList!.remove(dayMonday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseItem.dayList!.contains(dayMonday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('MO',
                                      style: widget.exerciseItem.dayList!.contains(dayMonday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(dayTuesday)) {
                                widget.exerciseItem.dayList!.add(dayTuesday);
                              } else {
                                widget.exerciseItem.dayList!.remove(dayTuesday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: width * 0.122,
                              color: widget.exerciseItem.dayList!.contains(dayTuesday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('TU',
                                      style: widget.exerciseItem.dayList!.contains(dayTuesday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(dayWednesday)) {
                                widget.exerciseItem.dayList!.add(dayWednesday);
                              } else {
                                widget.exerciseItem.dayList!.remove(dayWednesday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseItem.dayList!.contains(dayWednesday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('WE',
                                      style: widget.exerciseItem.dayList!.contains(dayWednesday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(dayThursday)) {
                                widget.exerciseItem.dayList!.add(dayThursday);
                              } else {
                                widget.exerciseItem.dayList!.remove(dayThursday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseItem.dayList!.contains(dayThursday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('TH',
                                      style: widget.exerciseItem.dayList!.contains(dayThursday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(dayFriday)) {
                                widget.exerciseItem.dayList!.add(dayFriday);
                              } else {
                                widget.exerciseItem.dayList!.remove(dayFriday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              color: widget.exerciseItem.dayList!.contains(dayFriday)
                                  ? ColorCode.mainColor
                                  : ColorCode.mainColor1,
                              child: Center(
                                  child: Text('FR',
                                      style: widget.exerciseItem.dayList!.contains(dayFriday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            splashColor: ColorCode.linearProgressBar,
                            onTap: () {
                              if (!widget.exerciseItem.dayList!.contains(daySaturday)) {
                                widget.exerciseItem.dayList!.add(daySaturday);
                              } else {
                                widget.exerciseItem.dayList!.remove(daySaturday);
                              }
                              widget.onExerciseItemUpdate(
                                  widget.index,
                                  workoutCategoryId,
                                  exerciseId,
                                  setController.text.trim(),
                                  repsController.text.trim(),
                                  secController.text.trim(),
                                  restController.text.trim(),
                                  widget.exerciseItem.dayList!);
                              hideKeyboard();
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              width: dayWidth,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
                                color: widget.exerciseItem.dayList!.contains(daySaturday)
                                    ? ColorCode.mainColor
                                    : ColorCode.mainColor1,
                              ),
                              child: Center(
                                  child: Text('SA',
                                      style: widget.exerciseItem.dayList!.contains(daySaturday)
                                          ? GymStyle.dayNameEnable
                                          : GymStyle.dayNameDisable)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
                onTap: () {
                  widget.onExerciseSelect(widget.exerciseItem);
                },
                child: SvgPicture.asset(
                  'assets/images/ic_Cancel.svg',
                  height: 30,
                  width: 30,
                )))
      ],
    );
  }
}

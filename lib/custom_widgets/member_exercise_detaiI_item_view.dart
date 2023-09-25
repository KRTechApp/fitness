// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/color_code.dart';
import '../model/workout_days_model.dart';
import '../providers/workout_history_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class ShowMemberExerciseDetailItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final WorkoutHistoryProvider workoutHistoryData;
  final List<ExerciseDataItem> exerciseDataList;
  final DateTime selectedDateTime;

  const ShowMemberExerciseDetailItemView({
    Key? key,
    required this.documentSnapshot,
    required this.workoutHistoryData,
    required this.exerciseDataList,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  State<ShowMemberExerciseDetailItemView> createState() => _ShowMemberExerciseDetailItemViewState();
}

class _ShowMemberExerciseDetailItemViewState extends State<ShowMemberExerciseDetailItemView> {
  var set = TextEditingController();
  var reps = TextEditingController();
  var sec = TextEditingController();
  var rest = TextEditingController();
  double progress = 0;
  String displayTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    // final QueryDocumentSnapshot queryDocumentSnapshot = exerciseData.memberExerciseListItem[index];
    List<ExerciseDataItem> trainerData =
        widget.exerciseDataList.where((element) => element.exerciseId == widget.documentSnapshot.id).toList();
    debugPrint('selectedIndex ${widget.workoutHistoryData.allWorkoutHistoryListItem.length}');
    debugPrint('widget.documentSnapshot.id ${widget.documentSnapshot.id}');
    List<QueryDocumentSnapshot> workoutHistory = widget.workoutHistoryData.allWorkoutHistoryListItem
        .where((element) =>
            element[keyExerciseId] == widget.documentSnapshot.id &&
            widget.selectedDateTime.isSameDate(DateTime.fromMillisecondsSinceEpoch(element[keyCreatedAt])))
        .toList();
    for (var element in widget.workoutHistoryData.allWorkoutHistoryListItem) {
      debugPrint("element[keyExerciseId] : ${workoutHistory.length}");
      debugPrint("Workout history : ${element[keyExerciseId]}");
    }
    debugPrint("exerciseDataList : ${widget.exerciseDataList.length}");
    debugPrint("trainerData length : ${trainerData.length}");
    if (workoutHistory.isNotEmpty &&
        trainerData.isNotEmpty &&
        widget.selectedDateTime.isSameDate(DateTime.fromMillisecondsSinceEpoch(workoutHistory.first[keyCreatedAt])) &&
        workoutHistory.first.get(keySet) != "") {
      progress = ((double.parse(workoutHistory.first.get(keyExerciseProgress) ?? "0")));
          // ((double.parse(workoutHistory.first.get(keySet) ?? "0")) / ((double.parse(trainerData.first.set ?? "0"))));
      debugPrint(
          'PrintValues : $progress');

      displayTime = workoutHistory.first.get(keyExerciseTime);

      set.text = "${workoutHistory.first.get(keySet) ?? "0"}/${trainerData.first.set ?? "0"}";
      reps.text = "${workoutHistory.first.get(keyReps) ?? "0"}/${trainerData.first.reps ?? "0"}";
      sec.text = "${workoutHistory.first.get(keySec) ?? "0"}/${trainerData.first.sec ?? "0"}";
      rest.text = "${workoutHistory.first.get(keyRest) ?? "0"}/${trainerData.first.rest ?? "0"}";
      debugPrint('display : $displayTime');
    } else if (trainerData.isNotEmpty) {
      set.text = "0/${trainerData.first.set ?? "0"}";
      reps.text = "0/${trainerData.first.reps ?? "0"}";
      sec.text = "0/${trainerData.first.sec ?? "0"}";
      rest.text = "0/${trainerData.first.rest ?? "0"}";
    }
    setState(() {});
    debugPrint('progress $progress');
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: customCard(
          blurRadius: 5,
          radius: 15,
          child: SizedBox(
            height: 142,
            width: width - 38,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FadeInImage(
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          image: customImageProvider(
                            url: widget.documentSnapshot[keyProfile] ?? "",
                          ),
                          placeholderFit: BoxFit.fitWidth,
                          placeholder: customImageProvider(),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return getPlaceHolder();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: width * 0.35,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.documentSnapshot[keyExerciseTitle] ?? "",
                                maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                            const SizedBox(
                              height: 3,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.watch_later_outlined, color: ColorCode.listSubTitle, size: 18),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  displayTime,
                                  style: GymStyle.listSubTitle2,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 1),
                          height: height * 0.05,
                          width: width * 0.26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                LinearProgressIndicator(
                                  minHeight: 50,
                                  value: progress, // percent filled
                                  valueColor: const AlwaysStoppedAnimation<Color>(ColorCode.mainColor),
                                  backgroundColor: ColorCode.linearProgressBar,
                                ),
                                Positioned(
                                    child: Center(
                                        child: Text(
                                            '${double.parse(progress.toStringAsFixed(2)) >= double.parse('1.0') ? 100 : double.parse(progress.toStringAsFixed(2)) * 100}%',
                                            style: GymStyle.progressText)))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SizedBox(
                        width: width * 0.183,
                        height: height * 0.05,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: set,
                          readOnly: true,
                          enableInteractiveSelection: false,
                          maxLength: 3,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_set;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              counterText: "",
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: ColorCode.listSubTitle2, width: 1.0),
                              ),
                              labelText: AppLocalizations.of(context)!.set,
                              labelStyle: GymStyle.inputText),
                          style: GymStyle.inputTextSmall,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    SizedBox(
                      width: width * 0.183,
                      height: height * 0.05,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: reps,
                        enableInteractiveSelection: false,
                        readOnly: true,
                        maxLength: 3,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.please_enter_reps;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            counterText: "",
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorCode.listSubTitle2, width: 1.0),
                            ),
                            labelText: AppLocalizations.of(context)!.reps,
                            labelStyle: GymStyle.inputText),
                        style: GymStyle.inputTextSmall,
                        onChanged: (value) {},
                      ),
                    ),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    SizedBox(
                      width: width * 0.183,
                      height: height * 0.05,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: sec,
                        readOnly: true,
                        enableInteractiveSelection: false,
                        maxLength: 3,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.please_enter_sec;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            counterText: "",
                            focusedBorder: const OutlineInputBorder(
                              borderSide:BorderSide(color: ColorCode.listSubTitle2, width: 1.0),
                            ),
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.sec,
                            labelStyle: GymStyle.inputText),
                        style: GymStyle.inputTextSmall,
                        onChanged: (value) {},
                      ),
                    ),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    SizedBox(
                      width: width * 0.183,
                      height: height * 0.05,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: rest,
                        enableInteractiveSelection: false,
                        readOnly: true,
                        maxLength: 3,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.please_enter_rest;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            counterText: "",
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorCode.listSubTitle2, width: 1.0),
                            ),
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.rest,
                            labelStyle: GymStyle.inputText),
                        style: GymStyle.inputTextSmall,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
              ],
            ),
          )),
    );
  }
}

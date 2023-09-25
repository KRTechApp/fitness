import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../model/exercise_data_model.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class RearrangeExerciseListItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final List<String> selectExercise;
  final List<ExerciseDataModel> selectExerciseList;
  final Function(String selectedId, bool selected) onExerciseItemSelected;
  final Function(String, String, String, String, String) onExerciseItemUpdate;

  const RearrangeExerciseListItemView({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.selectExercise,
    required this.selectExerciseList,
    required this.onExerciseItemSelected,
    required this.onExerciseItemUpdate,
  }) : super(key: key);

  @override
  State<RearrangeExerciseListItemView> createState() => _RearrangeExerciseListItemViewState();
}

class _RearrangeExerciseListItemViewState extends State<RearrangeExerciseListItemView> {
  var setController = TextEditingController();
  var repsController = TextEditingController();
  var secController = TextEditingController();
  var restController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int index = widget.selectExerciseList.indexWhere((element) => element.id == widget.queryDocumentSnapshot.id);
    if (index != -1) {
      setController.text = widget.selectExerciseList[index].set ?? "";
      repsController.text = widget.selectExerciseList[index].reps ?? "";
      secController.text = widget.selectExerciseList[index].sec ?? "";
      restController.text = widget.selectExerciseList[index].rest ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: customCard(
        blurRadius: 5,
        radius: 15,
        child: Row(
          children: [
            SizedBox(
              height: 140,
              width: width - 38,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: SvgPicture.asset(
                          'assets/images/rearrange.svg',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            image: customImageProvider(
                              url: widget.queryDocumentSnapshot[keyProfile],
                            ),
                            placeholderFit: BoxFit.fitWidth,
                            placeholder: customImageProvider(),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return getPlaceHolder();
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(widget.queryDocumentSnapshot[keyExerciseTitle] ?? "",
                            maxLines: 1, style: GymStyle.listTitle, overflow: TextOverflow.ellipsis),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(right: 15),
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.selectExercise.contains(widget.queryDocumentSnapshot.id)) {
                              widget.onExerciseItemSelected(widget.queryDocumentSnapshot.id, false);
                            } else {
                              widget.onExerciseItemSelected(widget.queryDocumentSnapshot.id, true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(
                                width: 1.0,
                                color: ColorCode.mainColor,
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.selected.toUpperCase(),
                            style: const TextStyle(
                                color: ColorCode.mainColor,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: SizedBox(
                          width: width * 0.183,
                          height: height * 0.05,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: setController,
                            onChanged: (value) {
                              widget.onExerciseItemUpdate(
                                widget.queryDocumentSnapshot.id,
                                setController.text.trim(),
                                repsController.text.trim(),
                                secController.text.trim(),
                                restController.text.trim(),
                              );
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.please_enter_set;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.set,
                              labelStyle: GymStyle.smalltTextinput,
                            ),
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
                          controller: repsController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_reps;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.reps,
                            labelStyle: GymStyle.smalltTextinput,
                          ),
                          onChanged: (value) {
                            widget.onExerciseItemUpdate(
                              widget.queryDocumentSnapshot.id,
                              setController.text.trim(),
                              repsController.text.trim(),
                              secController.text.trim(),
                              restController.text.trim(),
                            );
                          },
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
                          controller: secController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_sec;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.sec,
                            labelStyle: GymStyle.smalltTextinput,
                          ),
                          onChanged: (value) {
                            widget.onExerciseItemUpdate(
                              widget.queryDocumentSnapshot.id,
                              setController.text.trim(),
                              repsController.text.trim(),
                              secController.text.trim(),
                              restController.text.trim(),
                            );
                          },
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
                          controller: restController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_rest;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.rest,
                            labelStyle: GymStyle.smalltTextinput,
                          ),
                          onChanged: (value) {
                            widget.onExerciseItemUpdate(
                              widget.queryDocumentSnapshot.id,
                              setController.text.trim(),
                              repsController.text.trim(),
                              secController.text.trim(),
                              restController.text.trim(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

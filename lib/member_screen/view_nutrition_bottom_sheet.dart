import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/gym_style.dart';

class ViewNutritionBottomSheet extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;

  const ViewNutritionBottomSheet({super.key, required this.documentSnapshot});

  @override
  State<ViewNutritionBottomSheet> createState() =>
      _ViewNutritionBottamSheetState();
}

class _ViewNutritionBottamSheetState extends State<ViewNutritionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.65,
      width: width,
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/arrow-left.svg'),
                  ),
                  SizedBox(width: width * 0.03),
                  SizedBox(
                    width: width * 0.7,
                    child: widget.documentSnapshot[keyNutritionName].length > 18
                        ? SizedBox(
                            width: width * 0.52,
                            height: 29,
                            child: Marquee(
                              text: widget.documentSnapshot[keyNutritionName] ??
                                  "",
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 50.0,
                              velocity: 20.0,
                              pauseAfterRound: const Duration(seconds: 1),
                              accelerationDuration: const Duration(seconds: 2),
                              accelerationCurve: Curves.linear,
                              decelerationDuration:
                                  const Duration(milliseconds: 200),
                              decelerationCurve: Curves.easeOut,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                          )
                        : Text(
                            widget.documentSnapshot[keyNutritionName] ?? "",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                          ),
                    /*Text(
                          widget.documentSnapshot[keyClassName],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),*/
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.start_date.allInCaps,
                          maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(
                            DateFormat(StaticData.currentDateFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.documentSnapshot.get(keyStartDate))),
                            style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(
                      color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.end_date.allInCaps,
                          maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(
                            DateFormat(StaticData.currentDateFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.documentSnapshot.get(keyEndDate))),
                            style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(
                      color: Color(0xFFE1E3E6), thickness: 1, height: 25),

                  const SizedBox(height: 10),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .nutrition_detail
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyNutritionDetail))
                        ],
                      )),
                  const SizedBox(height: 20),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .break_fast_nutrition
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyBreakFast))
                        ],
                      )),const SizedBox(height: 20),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .mid_morning_snacks
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyMidMorningSnacks))
                        ],
                      )),const SizedBox(height: 20),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .lunch
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyLunch))
                        ],
                      )),const SizedBox(height:20),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .afternoon_snacks
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyAfternoonSnacks))
                        ],
                      )),const SizedBox(height: 20),
                  Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorCode.tabDivider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .dinner
                                  .allInCaps,
                              style: GymStyle.boldText),
                          Text(widget.documentSnapshot.get(keyDinner))
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

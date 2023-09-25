import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class WorkoutDetailCardView extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const WorkoutDetailCardView({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<WorkoutDetailCardView> createState() => _WorkoutDetailCardViewState();
}

class _WorkoutDetailCardViewState extends State<WorkoutDetailCardView> {
  final random = Random();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(
            height: 130,
            width: width,
            margin: const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
              color: StaticData.workoutColorList[random.nextInt(StaticData.workoutColorList.length)],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*  if ((documentSnapshot[keyWorkoutType] ?? "") == "free")
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  height: 26,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: ColorCode.workoutMembership,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.free_for_all,
                                    style: const TextStyle(color: ColorCode.white, fontSize: 12),
                                  ),
                                ),
                              if ((documentSnapshot[keyWorkoutType] ?? "") == "premium")
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  height: 26,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: ColorCode.workoutPremiumMembership,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/images/star.svg',
                                          color: ColorCode.workoutPremiumMembershipText),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          AppLocalizations.of(context)!.premium,
                                          style:
                                          const TextStyle(color: ColorCode.workoutPremiumMembershipText, fontSize: 12),
                                        ),
                                      )
                                    ],
                                  ),
                                ),*/
                      Text(
                        widget.documentSnapshot[keyWorkoutFor] ?? "",
                        style: GymStyle.containerSubHeader3,
                      ),
                      customMarquee(
                          width: width * 0.52,
                          text: widget.documentSnapshot[keyWorkoutTitle],
                          textStyle: GymStyle.containerHeader2,
                          height: 30),
                      Row(
                        children: [
                          const Icon(Icons.watch_later_outlined, color: Colors.white),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                            ),
                            child: Text(
                                "${((widget.documentSnapshot[keyTotalWorkoutTime] ?? 0) / 60).ceil().toString()} min",
                                style: GymStyle.containerSubHeader2),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 4),
                            child: SvgPicture.asset(
                              'assets/images/dumbbell.svg',
                              width: 15,
                              height: 15,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              '${widget.documentSnapshot[keyExerciseCount] ?? ""} ${AppLocalizations.of(context)!.exercises}',
                              style: GymStyle.containerSubHeader2,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            left: 165,
            child: Image.asset('assets/images/Circle.png', color: Colors.white, height: 200),
          ),
          Positioned(
            bottom: 15,
            right: 14,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: FadeInImage(
                fit: BoxFit.fill,
                width: 132,
                height: 130,
                image: customImageProvider(
                  url: widget.documentSnapshot[keyProfile],
                ),
                placeholderFit: BoxFit.fitWidth,
                placeholder: customImageProvider(),
                imageErrorBuilder: (context, error, stackTrace) {
                  return getPlaceHolder();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

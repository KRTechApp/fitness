import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/trainer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../admin_screen/workout_detail_screen.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class AssignWorkoutToMemberItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String userRole;
  final String userId;
  final List<String> selectedWorkoutList;
  final int index;
  final Function(String workoutId, bool selected) onSelectedWorkout;

  const AssignWorkoutToMemberItemView(
      {Key? key,
      required this.queryDocumentSnapshot,
      required this.userRole,
      required this.userId,
      required this.selectedWorkoutList,
      required this.onSelectedWorkout,
      required this.index})
      : super(key: key);

  @override
  State<AssignWorkoutToMemberItemView> createState() => _AssignWorkoutToMemberItemViewState();
}

class _AssignWorkoutToMemberItemViewState extends State<AssignWorkoutToMemberItemView> {
  final random = Random();
  late TrainerProvider trainerProvider;

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Checkbox(
          activeColor: const Color(0xFF6842FF),
          value: widget.selectedWorkoutList.contains(widget.queryDocumentSnapshot.id),
          onChanged: (bool? value) {
            if (widget.selectedWorkoutList.contains(widget.queryDocumentSnapshot.id)) {
              widget.onSelectedWorkout(widget.queryDocumentSnapshot.id, false);
            } else {
              widget.onSelectedWorkout(widget.queryDocumentSnapshot.id, true);
            }
          },
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutDetailScreen(
                    documentSnapshot: widget.queryDocumentSnapshot,
                    userRole: widget.userRole,
                    workoutCreatedBy: widget.queryDocumentSnapshot[keyCreatedBy]),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 132,
                width: width - 65,
                margin: const EdgeInsets.only(top: 15, right: 15),
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
                          if ((widget.queryDocumentSnapshot[keyWorkoutType] ?? "") == "free")
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
                          if ((widget.queryDocumentSnapshot[keyWorkoutType] ?? "") == "premium")
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
                            ),
                          Text(
                            widget.queryDocumentSnapshot[keyWorkoutFor] ?? "",
                            style: GymStyle.containerSubHeader3,
                          ),
                          widget.queryDocumentSnapshot[keyWorkoutTitle].length > 16
                              ? SizedBox(
                                  width: width * 0.5,
                                  height: 25,
                                  child: Marquee(
                                    text: widget.queryDocumentSnapshot[keyWorkoutTitle] ?? "",
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    blankSpace: 50.0,
                                    velocity: 20.0,
                                    pauseAfterRound: const Duration(seconds: 1),
                                    accelerationDuration: const Duration(seconds: 2),
                                    accelerationCurve: Curves.linear,
                                    decelerationDuration: const Duration(milliseconds: 200),
                                    decelerationCurve: Curves.easeOut,
                                    style: GymStyle.containerHeader2,
                                  ),
                                )
                              : Text(
                                  widget.queryDocumentSnapshot[keyWorkoutTitle] ?? "",
                                  style: GymStyle.containerHeader2,
                                ),
                          widget.userRole == userRoleAdmin
                              ? Row(
                                  children: [
                                    const Icon(Icons.man_rounded, color: Colors.white),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: FutureBuilder(
                                        future: trainerProvider.getTrainerFromId(
                                            memberId: widget.queryDocumentSnapshot.get(keyCreatedBy),
                                            createdBy: widget.userId),
                                        builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                          if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                            var queryDoc = asyncSnapshot.data;
                                            return Text(queryDoc![keyName],
                                                maxLines: 1, style: GymStyle.containerSubHeader2);
                                          }
                                          return Container();
                                        },
                                      ),
                                      /*Text(
                              widget.queryDocumentSnapshot[keyWorkoutTitle] ??"",
                              style: GymStyle.containerSubHeader2,
                            ),*/
                                    ),
                                  ],
                                )
                              : Row(children: [
                                  const Icon(Icons.watch_later_outlined, color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                        "${((widget.queryDocumentSnapshot[keyTotalWorkoutTime] ?? 0) / 60).ceil().toString()} min",
                                        style: GymStyle.containerSubHeader2),
                                  )
                                ]),
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
                bottom: 0,
                right: 14,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                  child: FadeInImage(
                    fit: BoxFit.fitHeight,
                    width: 132,
                    height: 132,
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
            ],
          ),
        )
      ],
    );
  }
}

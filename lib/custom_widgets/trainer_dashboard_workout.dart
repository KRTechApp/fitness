import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';

import '../admin_screen/workout_detail_screen.dart';
import '../main.dart';
import '../mobile_pages/member_workout_detail_screen.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';
import 'expired_dailog.dart';

class TrainerDashboardWorkout extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String userRole;
  final String userId;

  const TrainerDashboardWorkout(
      {Key? key, required this.queryDocumentSnapshot, required this.userRole, required this.userId})
      : super(key: key);

  @override
  State<TrainerDashboardWorkout> createState() => _TrainerDashboardWorkoutState();
}

class _TrainerDashboardWorkoutState extends State<TrainerDashboardWorkout> {
  final random = Random();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if(isExpired){
          PlanExpiredDialog(context,widget.userRole,);
          return;
        }
        widget.userRole == userRoleMember
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberWorkoutDetailScreen(
                    documentSnapshot: widget.queryDocumentSnapshot,
                    userRole: widget.userRole,
                    userId: widget.userId,
                  ),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutDetailScreen(
                      documentSnapshot: widget.queryDocumentSnapshot,
                      userRole: widget.userRole,
                      workoutCreatedBy: widget.queryDocumentSnapshot[keyCreatedBy]),
                ),
              );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              height: 180,
              width: width * 0.85,
              margin: const EdgeInsets.only(top: 15, right: 15),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                color: StaticData.colorList[random.nextInt(StaticData.colorList.length)].withOpacity(0.50),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 0, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.38,
                      child: Text(
                        widget.queryDocumentSnapshot[keyWorkoutTitle] ?? "",
                        style: GymStyle.containerHeader,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            color: const Color(0xFF555555),
                            'assets/images/ic_Watch.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '${widget.queryDocumentSnapshot[keyDuration] ?? ""} ${AppLocalizations.of(context)!.weeks}',
                              style: GymStyle.containerSubHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            color: const Color(0xFF555555),
                            'assets/images/Videos.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '${widget.queryDocumentSnapshot[keyExerciseCount] ?? ""} ${AppLocalizations.of(context)!.attachment}',
                              style: GymStyle.containerSubHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            color: const Color(0xFF555555),
                            'assets/images/dumbbell.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '${widget.queryDocumentSnapshot[keyExerciseCount] ?? ""} ${AppLocalizations.of(context)!.exercises}',
                              style: GymStyle.containerSubHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.userRole == userRoleMember)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.lets_start,
                              style: GymStyle.containerLowarText,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SvgPicture.asset(
                                color: const Color(0xFF181A20),
                                'assets/images/ic_arrow_right.svg',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              height: 180,
              right: 15,
              top: 15,
              child: Image.asset('assets/images/Circle.png'),
            ),
            Positioned(
              right: 15,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                child: FadeInImage(
                  fit: BoxFit.cover,
                  width: 175,
                  height: 176,
                  image: customImageProvider(
                    url: widget.queryDocumentSnapshot[keyProfile],
                  ),
                  placeholderFit: BoxFit.fill,
                  placeholder: customImageProvider(),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return getPlaceHolder();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
